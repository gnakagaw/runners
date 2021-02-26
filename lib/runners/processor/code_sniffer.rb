module Runners
  class Processor::CodeSniffer < Processor
    include PHP

    Schema = _ = StrongJSON.new do
      # @type self: SchemaClass

      let :runner_config, Runners::Schema::BaseConfig.base.update_fields { |fields|
        fields.merge!({
                        version: enum?(string, numeric),
                        dir: string?,
                        standard: string?,
                        extensions: enum?(string, array(string)),
                        encoding: string?,
                        ignore: enum?(string, array(string)),
                        # DO NOT ADD ANY OPTION under `options`.
                        options: optional(object(
                                            dir: string?,
                                            standard: string?,
                                            extensions: string?,
                                            encoding: string?,
                                            ignore: string?
                                          ))
                      })
      }

      let :issue, object(
        type: string,
        severity: integer,
        fixable: boolean,
      )
    end

    register_config_schema(name: :code_sniffer, schema: Schema.runner_config)

    DefaultOptions = _ = Struct.new(:standard, :extensions, :dir, keyword_init: true)
    OPTIONS_CAKE_PHP = DefaultOptions.new(standard: "CakePHP", extensions: "php", dir: "app/").freeze
    OPTIONS_SYMFONY = DefaultOptions.new(standard: "Symfony", extensions: "php", dir: "src/").freeze
    OPTIONS_PSR2 = DefaultOptions.new(standard: "PSR2", extensions: "php", dir: "./").freeze

    def self.config_example
      <<~'YAML'
        root_dir: project/
        dir: app/
        standard: CakePHP
        extensions: [php, inc]
        encoding: utf-8
        ignore:
          - app/vendor/
      YAML
    end

    def analyzer_bin
      "phpcs"
    end

    def setup
      add_warning_if_deprecated_options
      yield
    end

    def analyze(changes)
      capture3!(
        analyzer_bin,
        "--report=json",
        "--report-json=#{report_file}",
        "-q", # Enable quiet mode. See https://github.com/squizlabs/PHP_CodeSniffer/wiki/Advanced-Usage#quieting-output
        "--runtime-set", "ignore_errors_on_exit", "1", # See https://github.com/squizlabs/PHP_CodeSniffer/wiki/Configuration-Options#ignoring-errors-when-generating-the-exit-code
        "--runtime-set", "ignore_warnings_on_exit", "1", # See https://github.com/squizlabs/PHP_CodeSniffer/wiki/Configuration-Options#ignoring-warnings-when-generating-the-exit-code
        *additional_options,
        directory,
      )

      issues = []

      read_report_json.fetch(:files).each do |file, suggests|
        path = relative_path(file.to_s)

        suggests.fetch(:messages).each do |suggest|
          issues << Issue.new(
            path: path,
            location: Location.new(start_line: suggest[:line], start_column: suggest[:column]),
            id: suggest[:source],
            message: suggest[:message],
            object: {
              type: suggest[:type],
              severity: suggest[:severity],
              fixable: suggest[:fixable],
            },
            schema: Schema.issue,
          )
        end
      end

      issues.uniq! { |issue| [issue.path, issue.location, issue.id, issue.message] }

      Results::Success.new(guid: guid, analyzer: analyzer, issues: issues)
    end

    private

    def additional_options
      if config_linter.empty?
        ["--standard=#{default_options.standard}", "--extensions=#{default_options.extensions}"]
      else
        [standard_option, extensions_option, *encoding_option, *ignore_option]
      end
    end

    def standard_option
      standard = config_linter[:standard] || config_linter.dig(:options, :standard) || default_options.standard
      "--standard=#{standard}"
    end

    def extensions_option
      extensions = config_linter[:extensions] || config_linter.dig(:options, :extensions) || default_options.extensions
      extensions = comma_separated_list(extensions)
      "--extensions=#{extensions}"
    end

    def encoding_option
      encoding = config_linter[:encoding] || config_linter.dig(:options, :encoding)
      encoding ? ["--encoding=#{encoding}"] : []
    end

    def ignore_option
      ignore = config_linter[:ignore] || config_linter.dig(:options, :ignore)
      ignore = comma_separated_list(ignore)
      ignore ? ["--ignore=#{ignore}"] : []
    end

    def directory
      config_linter[:dir] || config_linter.dig(:options, :dir) || default_options.dir
    end

    def default_options
      @default_options ||=
        case php_framework
        when :CakePHP
          OPTIONS_CAKE_PHP
        when :Symfony
          OPTIONS_SYMFONY
        else
          OPTIONS_PSR2
        end
    end

    def php_framework
      return :CakePHP if File.exist? 'lib/Cake/Core/CakePlugin.php'
      return :Symfony if File.exist? 'app/SymfonyRequirements.php'
      nil
    end
  end
end
