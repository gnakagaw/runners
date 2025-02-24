module Runners
  class Processor::Phpmd < Processor
    include PHP

    SCHEMA = _ = StrongJSON.new do
      extend Schema::ConfigTypes

      # @type self: SchemaClass
      let :config, base(
        target: target,
        rule: one_or_more_strings?,
        minimumpriority: numeric?,
        suffixes: one_or_more_strings?,
        exclude: one_or_more_strings?,
        strict: boolean?,
        custom_rule_path: one_or_more_strings?,
      )
    end

    register_config_schema(name: :phpmd, schema: SCHEMA.config)

    DEFAULT_TARGET = ".".freeze
    DEFAULT_CONFIG_FILE = (Pathname(Dir.home) / "sider_config.xml").to_path.freeze

    def self.config_example
      <<~'YAML'
        root_dir: project/
        target: [src/, test/]
        rule: [cleancode, codesize]
        minimumpriority: 3
        suffixes: [php, phtml]
        exclude: [vendor/, "test/*.php"]
        strict: true
        custom_rule_path:
          - Custom_PHPMD_Rule.php
          - "custom/phpmd/rules/**/*.php"
      YAML
    end

    def analyze(changes)
      delete_unchanged_files(changes, only: target_files, except: Array(config_linter[:custom_rule_path]))
      run_analyzer(changes)
    end

    private

    def target_files
      _, value = suffixes
      value&.split(",")&.map { |suffix| "*.#{suffix}" } || ["*.php"]
    end

    def rule
      comma_separated_list(config_linter[:rule]) || DEFAULT_CONFIG_FILE
    end

    def target_dirs
      comma_separated_list(config_linter[:target]) || DEFAULT_TARGET
    end

    def minimumpriority
      priority = config_linter[:minimumpriority]
      priority ? ["--minimumpriority", priority.to_s] : []
    end

    def suffixes
      suffixes = comma_separated_list(config_linter[:suffixes])
      suffixes ? ["--suffixes", suffixes] : []
    end

    def exclude
      exclude = comma_separated_list(config_linter[:exclude])
      exclude ? ["--exclude", exclude] : []
    end

    def strict
      strict = config_linter[:strict]
      strict ? ["--strict"] : []
    end

    def run_analyzer(changes)
      # PHPMD exits 1 when some violations are found.
      # The `--ignore-violation-on-exit` will exit with a zero code, even if any violations are found.
      # See https://phpmd.org/documentation/index.html
      _stdout, stderr, status = capture3(
        analyzer_bin,
        target_dirs,
        "xml",
        rule,
        "--ignore-violations-on-exit",
        "--report-file", report_file,
        *minimumpriority,
        *suffixes,
        *exclude,
        *strict,
      )

      unless status.success?
        if stderr.include? "Cannot find specified rule-set"
          return Results::Failure.new(guid: guid, analyzer: analyzer, message: "Invalid rule: #{rule.inspect}")
        elsif !stderr.empty?
          raise stderr
        else
          raise status.inspect
        end
      end

      begin
        xml_root = read_report_xml
      rescue InvalidXML => exn
        return Results::Failure.new(guid: guid, analyzer: analyzer, message: exn.message)
      end

      raise "XML must not be empty" unless xml_root

      change_paths = changes.changed_paths
      errors = []
      xml_root.each_element('error') do |error|
        filename = error[:filename] or raise "Filename must not be empty: #{error.inspect}"
        errors << error[:msg] if change_paths.include?(relative_path(filename))
      end
      unless errors.empty?
        errors.each { |message| trace_writer.error message }
        return Results::Failure.new(guid: guid, message: errors.join("\n"), analyzer: analyzer)
      end

      Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
        xml_root.each_element('file') do |file|
          filename = file[:name] or raise "Filename must not be empty: #{file.inspect}"
          path = relative_path(filename)

          file.each_element('violation') do |violation|
            message = violation.text or raise "required message: #{violation.inspect}"

            result.add_issue Issue.new(
              path: path,
              location: Location.new(start_line: violation[:beginline], end_line: violation[:endline]),
              id: violation[:rule],
              message: message.strip,
              links: violation[:externalInfoUrl].then { |url| url ? [url] : [] },
            )
          end
        end
      end
    end
  end
end
