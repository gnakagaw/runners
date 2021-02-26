module Runners
  class Processor::SlimLint < Processor
    include Ruby
    include RuboCopUtils

    Schema = _ = StrongJSON.new do
      # @type self: SchemaClass

      let :runner_config, Schema::BaseConfig.ruby.update_fields { |fields|
        fields.merge!({
          target: enum?(string, array(string)),
          config: string?,
        })
      }

      let :issue, object(
        severity: string,
      )
    end

    register_config_schema(name: :slim_lint, schema: Schema.runner_config)

    GEM_NAME = "slim_lint".freeze
    REQUIRED_GEM_NAMES = ["rubocop"].freeze
    CONSTRAINTS = {
      GEM_NAME => [">= 0.20.2", "< 1.0.0"]
    }.freeze
    DEFAULT_TARGET = ".".freeze
    DEFAULT_CONFIG_FILE = (Pathname(Dir.home) / "sider_recommended_slim_lint.yml").to_path.freeze
    MISSING_ID = "missing-ID".freeze

    def self.config_example
      <<~'YAML'
        root_dir: project/
        gems:
          - { name: rubocop, version: 1.0.0 }
        target: [app/views/]
        config: config/.slim-lint.yml
      YAML
    end

    def analyzer_bin
      "slim-lint"
    end

    def setup
      setup_slim_lint_config

      default_gems = default_gem_specs(GEM_NAME, *REQUIRED_GEM_NAMES)

      if setup_default_rubocop_config
        # NOTE: See `Processor::RuboCop` about no versions.
        default_gems << GemInstaller::Spec.new(name: "meowcop", version: [])
      end

      optionals = official_rubocop_plugins + third_party_rubocop_plugins
      install_gems(default_gems, optionals: optionals, constraints: CONSTRAINTS) { yield }
    rescue InstallGemsFailure => exn
      trace_writer.error exn.message
      return Results::Failure.new(guid: guid, message: exn.message)
    end

    def analyze(_changes)
      cmd = ruby_analyzer_command(
        *(config_linter[:config].then { |config| config ? ["--config", config] : [] }),
        *Array(config_linter[:target] || DEFAULT_TARGET),
      )

      stdout, stderr, status = capture3(cmd.bin, *cmd.args)

      # @see https://github.com/sds/slim-lint/blob/v0.20.2/lib/slim_lint/cli.rb#L11-L16
      case status.exitstatus
      when 0, 65
        Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
          parse_result(stdout) do |issue|
            result.add_issue(issue)
          end
        end
      when 67, 78
        Results::Failure.new(guid: guid, analyzer: analyzer, message: stdout.strip)
      else
        raise "#{stdout}\n#{stderr}"
      end
    end

    private

    def setup_slim_lint_config
      return if config_linter[:config]

      path = current_dir / ".slim-lint.yml"
      return if path.exist?

      FileUtils.copy_file DEFAULT_CONFIG_FILE, path
      trace_writer.message "Set up the default #{analyzer_name} configuration file."
    end

    def parse_result(output)
      # NOTE: The Slim-Lint JSON repoter does not output linter names, so we cannot set issue IDs.
      # @see https://github.com/sds/slim-lint/blob/v0.20.2/lib/slim_lint/reporter/json_reporter.rb

      # @see https://github.com/sds/slim-lint/blob/v0.20.2/lib/slim_lint/reporter/default_reporter.rb
      pattern = /^(.+):(\d+) \[(E|W)\] (?:(.+): )?(.+)$/
      severities = { "E" => "error", "W" => "warning" }

      output.scan(pattern) do |path, line, severity, id, message|
        path.is_a?(String) or raise
        line.is_a?(String) or raise
        severity.is_a?(String) or raise
        message.is_a?(String) or raise

        issue_id = build_id(id)

        yield Issue.new(
          path: relative_path(path),
          location: Location.new(start_line: line),
          id: issue_id,
          message: message,
          links: build_links(issue_id),
          object: {
            severity: severities.fetch(severity),
          },
          schema: Schema.issue,
        )
      end
    end

    def build_id(id)
      case
      when id.nil?
        MISSING_ID
      when id.start_with?("RuboCop:")
        id.delete(" ")
      else
        id
      end
    end

    def build_links(id)
      case id
      when nil, MISSING_ID
        []
      when /\ARuboCop:/
        cop_name = id.delete_prefix("RuboCop:")
        ["#{analyzer_github}/blob/v#{analyzer_version}/lib/slim_lint/linter/README.md#rubocop"] + build_rubocop_links(cop_name)
      else
        ["#{analyzer_github}/blob/v#{analyzer_version}/lib/slim_lint/linter/README.md##{id.downcase}"]
      end
    end
  end
end
