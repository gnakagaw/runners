module Runners
  class Processor::Querly < Processor
    include Ruby

    Schema = _ = StrongJSON.new do
      # @type self: SchemaClass

      let :runner_config, Schema::BaseConfig.ruby.update_fields { |fields|
        fields.merge!({
          config: string?,
        })
      }

      let :rule, object(
        id: string,
        messages: array?(string),
        justifications: array?(string),
        examples: array?(object(before: string?, after: string?)),
      )
    end

    register_config_schema(name: :querly, schema: Schema.runner_config)

    OPTIONAL_GEMS = [
      GemInstaller::Spec.new(name: "slim", version: []),
      GemInstaller::Spec.new(name: "haml", version: []),
    ].freeze

    GEM_NAME = "querly".freeze
    CONSTRAINTS = {
      GEM_NAME => [">= 0.5.0", "< 2.0.0"]
    }.freeze

    CONFIG_FILE = "querly.yml".freeze
    CONFIG_FILES_GLOB = "querly.{yml,yaml}".freeze

    def self.config_example
      <<~'YAML'
        root_dir: project/
        gems:
          - { name: "querly", version: "< 2" }
        config: config/querly.yml
      YAML
    end

    def extract_version_option
      "version"
    end

    def setup
      install_gems(default_gem_specs(GEM_NAME), optionals: OPTIONAL_GEMS, constraints: CONSTRAINTS) { yield }
    rescue InstallGemsFailure => exn
      trace_writer.error exn.message
      return Results::Failure.new(guid: guid, message: exn.message, analyzer: nil)
    end

    def analyze(changes)
      # NOTE: This check should be called after installing gems.
      if !config_file && !default_config_file
        return missing_config_file_result(CONFIG_FILE)
      end

      querly_test

      cmd = ruby_analyzer_command(
        "check",
        "--format=json",
        *option_config_file,
        ".",
      )
      stdout, _ = capture3!(cmd.bin, *cmd.args)

      json = JSON.parse(stdout, symbolize_names: true)

      Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
        Array(json[:issues]).each do |hash|
          # @type var hash: Hash[Symbol, untyped]
          start_line, start_column = hash[:location][:start]
          end_line, end_column = hash[:location][:end]
          rule = hash[:rule]
          message, _ = rule[:messages]

          result.add_issue Issue.new(
            path: relative_path(hash[:script]),
            location: Location.new(
              start_line: start_line,
              start_column: start_column,
              end_line: end_line,
              end_column: end_column,
            ),
            id: rule[:id],
            message: message || "No message",
            object: rule,
            schema: Schema.rule
          )
        end
      end
    end

    private

    def config_file
      config_linter[:config]
    end

    def option_config_file
      file = config_file
      file ? ["--config", file] : []
    end

    def default_config_file
      return @default_config_file if defined? @default_config_file

      config_files = Dir.glob(CONFIG_FILES_GLOB)

      if config_files.size > 1
        file_list = config_files.map { |file| "`#{file}`" }.join(', ')
        add_warning <<~MSG, file: CONFIG_FILE
          There are duplicate configuration files (#{file_list}). Remove the files except the first one.
        MSG
      end

      @default_config_file ||= config_files.first
    end

    def querly_test
      cmd = ruby_analyzer_command("test", *option_config_file)
      stdout, _stderr, _status = capture3(cmd.bin, *cmd.args)

      stdout.scan(/^  (\S+:\t.+)$/) do |message, _|
        if message.is_a? String
          add_warning message, file: config_file || default_config_file
        else
          raise "Scan failed: message=#{message.inspect}"
        end
      end
    end
  end
end
