module Runners
  class Processor::Remark < Processor
    include Nodejs

    Schema = StrongJSON.new do
      let :runner_config, Schema::BaseConfig.npm.update_fields { |fields|
        fields.merge!({
                        glob: string?,
                        config: string?,
                        "rc-path": string?,
                        "use": string?,
                        setting: string?,
                        # DO NOT ADD ANY OPTIONS in `options` option.
                        options: optional(object(
                                            config: string?,
                                            setting: string?,
                                            glob: string?
                                          ))
                      })
      }
    end

    DEFAULT_DEPS = DefaultDependencies.new(
      main: Dependency.new(name: "remark", version: "11.0.2"),
      extras: [
        Dependency.new(name: "remark-cli", version: "7.0.1"),
      ],
    )

    CONSTRAINTS = {
      "remark" => Constraint.new(">= 11.0.0"),
    }.freeze

    def self.ci_config_section_name
      'remark'
    end

    def setup
      add_warning_if_deprecated_options([:options], doc: "https://help.sider.review/tools/javascript/remark")

      ensure_runner_config_schema(Schema.runner_config) do |config|
        begin
          install_nodejs_deps(DEFAULT_DEPS, constraints: CONSTRAINTS, install_option: config[:npm_install])
        rescue UserError => exn
          return Results::Failure.new(guid: guid, message: exn.message, analyzer: nil)
        end

        analyzer # Must initialize after installation
        yield
      end
    end

    def analyzer_name
      'Remark'
    end

    def analyze _changes
      ensure_runner_config_schema(Schema.runner_config) do |config|

        check_runner_config(config) do |target, options|
          run_analyzer(target, options)
        end
      end
    end

    private

    def check_runner_config config
      target = target_glob config
      rc_path = rc_path config
      s = setting config
      u = use config

      additional_options = [rc_path, u, s].flatten.compact
      yield target, additional_options
    end

    def target_glob config
      if config[:glob]
        config[:glob]
      else
        "*.md"
      end
    end

    def rc_path config
      path = config[:"rc-path"]
      ["--rc-path", "#{path}"] if config[:"rc-path"]
    end

    def setting config
      setting = config[:setting] || config.dig(:options, :setting)
      ["--setting", "#{setting}"] if setting
    end

    def use config
      use = config[:use] || config.dig(:options, :use)
      ["--use", "#{use}"] if use
    end

    def run_analyzer target, options
      stdout, stderr, status = capture3(
        nodejs_analyzer_bin,
        target,
        "--report",
        "vfile-reporter-json",
        *options,
      )

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
