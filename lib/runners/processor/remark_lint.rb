module Runners
  class Processor::RemarkLint < Processor
    include Nodejs

    Schema = StrongJSON.new do
      let(:runner_config, Schema::BaseConfig.npm.update_fields { |fields|
        fields.merge!(
          glob: string?,
          config: string?,
          "rc-path": string?,
          use: string?,
          setting: string?,
        )
      })
    end

    register_config_schema(name: :remark, schema: Schema.runner_config)

    DEFAULT_DEPS = DefaultDependencies.new(
      main: Dependency.new(name: "remark-lint", version: "6.0.5"),
      extras: [
        Dependency.new(name: "remark-cli", version: "7.0.1"),
        Dependency.new(name: "remark-preset-lint-consistent", version: "2.0.3"),
        Dependency.new(name: "remark-preset-lint-markdown-style-guide", version: "2.1.3"),
        Dependency.new(name: "remark-preset-lint-recommended", version: "3.0.3"),
        Dependency.new(name: "vfile-reporter-json", version: "2.0.1"),
      ],
    )

    CONSTRAINTS = {
      "remark-lint" => Constraint.new(">= 6.0.5", "< 7.0.0"),
      "remark-cli" => Constraint.new(">= 7.0.1", "< 8.0.0"),
    }.freeze

    def analyzer_bin
      "remark"
    end

    def nodejs_analyzer_global_version
      @nodejs_analyzer_global_version ||= remark_lint_version!(global: true)
    end

    def nodejs_analyzer_local_version
      @nodejs_analyzer_local_version ||= remark_lint_version!
    end

    def setup
      begin
        install_nodejs_deps(DEFAULT_DEPS, constraints: CONSTRAINTS, install_option: config_linter[:npm_install])
      rescue UserError => exn
        return Results::Failure.new(guid: guid, message: exn.message, analyzer: nil)
      end
      analyzer # Must initialize after installation
      yield
    end

    def analyze(_changes)
      check_runner_config(config_linter) do |target, options|
        run_analyzer(target, options)
      end
    end

    private

    def remark_lint_version!(global: false)
      pkg = DEFAULT_DEPS.main.name
      args = %W[ls #{pkg} --depth=0 --json]
      stdout, _ =
        if global
          capture3! "npm", *args, trace_stdout: false, chdir: Pathname(Dir.home).join(analyzer_id)
        else
          capture3! "npm", *args, trace_stdout: false
        end
      JSON.parse(stdout).dig("dependencies", pkg, "version")
    end

    def check_runner_config(config)
      target = target_glob config
      rc_path = rc_path config
      s = setting config
      u = use config

      additional_options = [rc_path, u, s].flatten.compact
      yield target, additional_options
    end

    def target_glob(config)
      if config[:glob]
        config[:glob]
      else
        "*.md"
      end
    end

    def rc_path(config)
      path = config[:"rc-path"]
      ["--rc-path", "#{path}"] if config[:"rc-path"]
    end

    def setting(config)
      setting = config[:setting]
      ["--setting", "#{setting}"] if setting
    end

    def use(config)
      use = config[:use]
      ["--use", "#{use}"] if use
    end

    def run_analyzer(target, options)
      _, stderr, status = capture3(
        nodejs_analyzer_bin,
        target,
        "--report",
        "vfile-reporter-json",
        *options,
      )

      unless status.exited?
        return Results::Failure.new(guid: guid, message: "Process aborted or coredumped: #{status.inspect}", analyzer: analyzer)
      end

      unless status.exitstatus == 0 || status.exitstatus == 2
        return Results::Failure.new(guid: guid, message: stderr, analyzer: analyzer)
      end

      Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
        JSON.parse(stderr, symbolize_names: true).each do |file|
          file[:messages].each do |message|
            loc = Location.new(start_line: message.dig(:location, :start, :line),
                                            start_column: nil,
                                            end_line: message.dig(:location, :end, :line),
                                            end_column: nil)
            result.add_issue Issue.new(
              path: relative_path(file[:path]),
              location: loc,
              id: message[:ruleId],
              message: message[:reason],
            )
          end
        end
      end
    end
  end
end
