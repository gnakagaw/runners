module Runners
  class Processor::GolangCiLint < Processor
    include Go

    Schema =
      StrongJSON.new do
        let :runner_config,
            Schema::RunnerConfig.base.update_fields { |fields|
              fields.merge!(
                {
                  target: enum?(string, array(string)),
                  config: string?,
                  disable: enum?(string, array(string)),
                  'disable-all': boolean?,
                  enable: enum?(string, array(string)),
                  fast: boolean?,
                  'no-config': boolean?,
                  presets: enum?(string, array(string)),
                  'skip-dirs': enum?(string, array(string)),
                  'skip-dirs-use-default': boolean?,
                  'skip-files': enum?(string, array(string)),
                  tests: boolean?,
                  'uniq-by-line': boolean?
                }
              )
            }

        let :issue, object(severity: string?)
      end

    DEFAULT_TARGET = "./...".freeze

    def self.ci_config_section_name
      # Section name in sideci.yml, Generally it is the name of analyzer tool.
      "golangci-lint"
    end

    def analyzer_bin
      "golangci-lint"
    end

    def analyzer_name
      "golangci-lint"
    end

    def analyze(changes)
      ensure_runner_config_schema(Schema.runner_config) do |config|
        @config = config
        run_analyzer
      end
    end

    private

    # [ref] https://github.com/golangci/golangci-lint/blob/master/pkg/exitcodes/exitcodes.go
    #     Success              = 0
    #     IssuesFound          = 1
    #     WarningInTest        = 2
    #     Failure              = 3
    #     Timeout              = 4
    #     NoGoFiles            = 5
    #     NoConfigFileDetected = 6
    #     ErrorWasLogged       = 7

    def run_analyzer
      stdout, stderr, status = capture3(analyzer_bin, "run", *analyzer_options)
      if (status.exitstatus == 0 || status.exitstatus == 1) && stdout && stderr.empty?
        return(
          Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
            issues = parse_result(stdout)
            issues.each { |v| result.add_issue(v) } unless issues.nil?
          end
        )
      end

      if status.exitstatus == 3
        return Results::Failure.new(guid: guid, analyzer: analyzer, message: handle_respective_message(stderr))
      end

      if status.exitstatus == 5 && stderr.include?("no go files to analyze")
        return Results::Failure.new(guid: guid, analyzer: analyzer, message: "No go files to analyze")
      end

      Results::Failure.new(guid: guid, analyzer: analyzer, message: "Running error")
    end

    def handle_respective_message(stderr)
      case stderr
      when /must enable at least one/
        "Must enable at least one linter"
      when /can't be disabled and enabled at one moment/
        "Can't be disabled and enabled at one moment"
      when /can't combine options --disable-all and --disable/
        "Can't combine options --disable-all and --disable"
      when /only next presets exist/
        "Only next presets exist: (bugs|complexity|format|performance|style|unused)"
      when /no such linter/
        "No such linter"
      when /can't combine option --config and --no-config/
        "Can't combine option --config and --no-config"
      else
        msg = stderr.match(/level=error msg=.+\[(.+)\]/)
        msg && msg[1] ? msg[1] : "Running Error"
      end
    end

    def config
      @config or raise "Must be initialized!"
    end

    def analyzer_options
      [].tap do |opts|
        analysis_targets.each { |target| opts << target }
        opts << "--out-format=json"
        opts << "--issues-exit-code=0"
        opts << "--tests=false" if config[:tests] == false
        opts << "--config=#{config[:config]}" if config[:config]
        Array(config[:disable]).each { |disable| opts << "--disable=#{disable}" }
        Array(config[:enable]).each { |enable| opts << "--enable=#{enable}" }
        Array(config[:presets]).each { |preset| opts << "--presets=#{preset}" }
        Array(config[:'skip-dirs']).each { |dir| opts << "--skip-dirs=#{dir}" }
        Array(config[:'skip-files']).each { |file| opts << "--skip-files=#{file}" }

        opts << "--disable-all" if config[:'disable-all'] == true
        opts << "--uniq-by-line=false" if config[:'uniq-by-line'] == false
        opts << "--no-config=true" if config[:'no-config'] == true
        opts << "--skip-dirs-use-default=false" if config[:'skip-dirs-use-default'] == false
      end
    end

    def analysis_targets
      config[:target] ? Array(config[:target]) : Array(DEFAULT_TARGET)
    end

    # Output format:
    #
    #      ["{"Issues":[{"FromLinter":"govet","Text":"printf: Printf call has arguments but no formatting directives","SourceLines":["\tfmt.Printf(\\\"text\\\", awesome_text)\"],\"Replacement\":null,\"Pos\":{\"Filename\":\"test/smokes/golangci_lint/success/main.go\",\"Offset\":85,\"Line\":7,\"Column\":12}}],\"Report\":{\"Linters\":[{\"Name\":\"govet\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"bodyclose\"},{\"Name\":\"errcheck\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"golint\"},{\"Name\":\"staticcheck\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"unused\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"gosimple\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"stylecheck\"},{\"Name\":\"gosec\"},{\"Name\":\"structcheck\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"varcheck\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"interfacer\"},{\"Name\":\"unconvert\"},{\"Name\":\"ineffassign\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"dupl\"},{\"Name\":\"goconst\"},{\"Name\":\"deadcode\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"gocyclo\"},{\"Name\":\"gocognit\"},{\"Name\":\"typecheck\",\"Enabled\":true,\"EnabledByDefault\":true},{\"Name\":\"gofmt\"},{\"Name\":\"goimports\"},{\"Name\":\"maligned\"},{\"Name\":\"depguard\"},{\"Name\":\"misspell\"},{\"Name\":\"lll\"},{\"Name\":\"unparam\"},{\"Name\":\"dogsled\"},{\"Name\":\"nakedret\"},{\"Name\":\"prealloc\"},{\"Name\":\"scopelint\"},{\"Name\":\"gocritic\"},{\"Name\":\"gochecknoinits\"},{\"Name\":\"gochecknoglobals\"},{\"Name\":\"godox\"},{\"Name\":\"funlen\"},{\"Name\":\"whitespace\"},{\"Name\":\"wsl\"},{\"Name\":\"gomnd\"}]}}{ Issues: number, code: rule, message: description, column: number, file: filepath, level: level }
    #
    # Example:
    #
    #     {:FromLinter=>"govet", :Text=>"printf: Printf call has arguments but no formatting directives", :SourceLines=>["\tfmt.Printf(\"text\", awesome_text)"], :Replacement=>nil, :Pos=>{:Filename=>"test/smokes/golangci_lint/success/main.go", :Offset=>85, :Line=>7, :Column=>12}}
    #
    # @see https://github.com/hadolint/hadolint#rules
    # @param stdout [String]
    # TODO how to handle replacement
    def parse_result(stdout)
      json = JSON.parse(stdout, symbolize_names: true)
      return if json[:Issues].nil?

      json[:Issues].map do |file|
        path = relative_path(file[:Pos][:Filename])

        line = file[:Pos][:Line]
        id = file[:FromLinter]

        Issue.new(path: path, location: Location.new(start_line: line), id: id, message: file[:Text], links: [])
      end
    end
  end
end
