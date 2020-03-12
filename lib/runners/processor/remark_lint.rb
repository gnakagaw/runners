module Runners
  class Processor::RemarkLint < Processor
    include Nodejs

    Schema = StrongJSON.new do
      let(:runner_config, Schema::BaseConfig.npm.update_fields { |fields|
        fields.merge!(
          target: enum?(string, array(string)),
          ext: string?,
          "rc-path": string?,
          "ignore-path": string?,
          setting: enum?(string, array(string)),
          use: enum?(string, array(string)),
          config: boolean?,
          ignore: boolean?,
        )
      })
    end

    register_config_schema(name: :remark_lint, schema: Schema.runner_config)

    DEFAULT_DEPS = DefaultDependencies.new(
      main: Dependency.new(name: "remark-lint", version: "6.0.5"),
      extras: [
        Dependency.new(name: "remark-cli", version: "7.0.1"),
        Dependency.new(name: "remark-preset-lint-consistent", version: "2.0.3"),
        Dependency.new(name: "remark-preset-lint-markdown-style-guide", version: "2.1.3"),
        Dependency.new(name: "remark-preset-lint-recommended", version: "3.0.3"),
        Dependency.new(name: "remark-preset-lint-sider", version: "0.1.1"),
        Dependency.new(name: "vfile-reporter-json", version: "2.0.1"),
      ],
    )

    CONSTRAINTS = {
      "remark-lint" => Constraint.new(">= 6.0.0", "< 7.0.0"),
      "remark-cli" => Constraint.new(">= 7.0.0", "< 8.0.0"),
    }.freeze

    DEFAULT_TARGET = ".".freeze
    DEFAULT_PRESET = "remark-preset-lint-sider".freeze

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
      run_analyzer
    end

    private

    def remark_lint_version!(global: false)
      pkg = "remark-lint"
      chdir = global ? Pathname(Dir.home).join(analyzer_id) : nil
      deps = list_installed_nodejs_deps only: [pkg], chdir: chdir
      deps.fetch(pkg).tap do |version|
        raise "No version of `#{pkg}`" if version.empty?
      end
    end

    def analysis_target
      Array(config_linter[:target] || DEFAULT_TARGET)
    end

    def option_ext
      config_linter[:ext].then { |v| v ? ["--ext", v] : [] }
    end

    def option_rc_path
      config_linter[:"rc-path"].then { |v| v ? ["--rc-path", v] : [] }
    end

    def option_ignore_path
      config_linter[:"ignore-path"].then { |v| v ? ["--ignore-path", v] : [] }
    end

    def option_setting
      Array(config_linter[:setting]).flat_map { |v| ["--setting", v] }
    end

    def option_use
      Array(config_linter[:use]).flat_map { |v| ["--use", v] }
    end

    def option_config
      config_linter[:config] == false ? ["--no-config"] : []
    end

    def option_ignore
      config_linter[:ignore] == false ? ["--no-ignore"] : []
    end

    # @see https://github.com/unifiedjs/unified-engine/blob/master/doc/configure.md
    def no_rc_files?
      Dir.glob("**/.remarkrc{,.*}", File::FNM_DOTMATCH, base: current_dir).empty?
    end

    # @see https://github.com/unifiedjs/unified-engine/blob/master/doc/configure.md
    def no_config_in_package_json?
      !(package_json_path.exist? && package_json.key?(:remarkConfig))
    end

    def use_default_preset?
      !config_linter[:"rc-path"] &&
        !config_linter[:setting] &&
        !config_linter[:use] &&
        !config_linter[:config] &&
        no_rc_files? &&
        no_config_in_package_json?
    end

    def default_preset
      use_default_preset? ? ["--use", DEFAULT_PRESET] : []
    end

    def cli_options
      [
        *option_ext,
        *option_rc_path,
        *option_ignore_path,
        *option_setting,
        *option_use,
        *default_preset,
        *option_config,
        *option_ignore,
        "--report", "vfile-reporter-json",
        "--no-color",
        "--no-stdout",
      ]
    end

    def run_analyzer
      _, stderr, _ = capture3(nodejs_analyzer_bin, *cli_options, *analysis_target)

      Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
        parse_result(stderr) do |issue|
          result.add_issue issue
        end
      end
    end

    def parse_result(output)
      JSON.parse(output, symbolize_names: true).each do |file|
        path = relative_path(file[:path])

        file[:messages].each do |message|
          if message[:fatal]
            trace_writer.error <<~MSG
              #{message[:reason]}
              #{message[:stack]}
            MSG
            next
          end

          yield Issue.new(
            path: path,
            location: message[:line].then { |line| line ? Location.new(start_line: line) : nil },
            id: message[:ruleId],
            message: message[:reason],
          )
        end
      end
    end
  end
end
