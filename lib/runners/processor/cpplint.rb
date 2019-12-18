module Runners
  class Processor::Cpplint < Processor
    include Python

    Schema = StrongJSON.new do
      let :runner_config, Schema::RunnerConfig.base.update_fields { |fields|
        fields.merge!({
          target: enum?(string, array(string)),
          extensions: string?,
          headers: string?,
          filter: string?,
          linelength: integer?,
          exclude: enum?(string, array(string)),
        })
      }

      let :issue, object(
        confidence: string?,
      )
    end

    DEFAULT_TARGET = ".".freeze

    def self.ci_config_section_name
      "cpplint"
    end

    def analyzer_name
      "cpplint"
    end

    def analyze(changes)
      ensure_runner_config_schema(Schema.runner_config) do |config|
        @config = config
        run_analyzer
      end
    end

    private

    def config
      @config or raise "Must be initialized!"
    end

    def analyzer_options
      [].tap do |opts|
        opts << "--output=junit"
        opts << "--recursive"
        opts << "--extensions=#{config[:extensions]}" if config[:extensions]
        opts << "--headers=#{config[:headers]}" if config[:headers]
        opts << "--filter=#{config[:filter]}" if config[:filter]
        opts << "--linelength=#{config[:linelength]}" if config[:linelength]
        Array(config[:exclude]).each do |exclude|
          opts << "--exclude=#{exclude}"
        end
        Array(config[:target] || DEFAULT_TARGET).each do |target|
          opts << target
        end
      end
    end

    def run_analyzer
      _stdout, stderr, status = capture3 analyzer_bin, *analyzer_options

      if [0, 1].include? status.exitstatus
        xml_output = REXML::Document.new(stderr)&.root
        if xml_output
          Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
            parse_result(xml_output) do |issue|
              result.add_issue issue
            end
          end
        else
          Results::Failure.new(guid: guid, analyzer: analyzer, message: stderr)
        end
      else
        Results::Failure.new(guid: guid, analyzer: analyzer, message: stderr)
      end
    end

    # Output format:
    #
    #     {line}: {message} [{category}] [{confidence}]
    #
    # Example:
    #
    #     3: Tab found; better to use spaces [whitespace/tab] [1]
    #
    # @see https://github.com/cpplint/cpplint/blob/1.4.4/cpplint.py#L1151
    # @see https://github.com/cpplint/cpplint/blob/1.4.4/cpplint.py#L1441-L1448
    def parse_result(xml_doc)
      message_pattern = /([^:]+): (.+) \[(.+)\] \[(.+)\]/

      xml_doc.each_element("testcase") do |testcase|
        path = relative_path(testcase[:name])
        testcase.each_element("failure") do |failure|
          failure.text.split("\n").map(&:strip).each do |issue_line|
            matched = issue_line.match(message_pattern)
            if matched
              line, message, category, confidence = matched.captures
              no_line_number = (line == "0" || !line.match?(/\A\d+\z/))
              yield Issue.new(
                id: category,
                path: path,
                location: no_line_number ? nil : Location.new(start_line: line),
                message: message.strip,
                object: {
                  confidence: confidence,
                },
                schema: Schema.issue,
              )
            else
              raise "Unexpected message format: #{issue_line.inspect}"
            end
          end
        end
      end
    end
  end
end
