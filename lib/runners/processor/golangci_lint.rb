module Runners
  class Processor::GolangCiLint < Processor
    include Go

    Schema = StrongJSON.new do
      let :runner_config, Schema::RunnerConfig.base.update_fields { |fields|
        fields.merge!({
                        # target: enum?(string, array(string)),
                        config: string?,
                        disable: enum?(string, array(string)),
                        'disable-all': boolean?,
                        enable: enum?(string, array(string)),
                        fast: boolean?,
                        'no-config': boolean?,
                        presets: enum?(string, array(string)),
                        'skip-dirs': enum?(string, array(string)),
                        'skip-dirs-use-default': boolean?,
                        'skip-file': enum?(string, array(string)),
                        tests: boolean?,
                        timeout: numeric?,
                        'uniq-by-line': boolean?,
                      })
      }

      let :issue, object(
        severity: string?,
      )
    end

    DEFAULT_TARGET = "**/*.{go}".freeze

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
      stdout, stderr, status = capture3(analyzer_bin, 'run', *analyzer_options)
      if status.exitstatus == 0
        return Results::Success.new(guid: guid, analyzer: analyzer)
      end

      if status.exitstatus == 1 && stdout && stderr.empty?
        return Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
          parse_result(stdout).each { |v| result.add_issue(v) }
        end
      end

      # TODO this pattern may not be failure but could not find the condition yet
      if status.exitstatus == 2
        Results::Failure.new(guid: guid, analyzer: analyzer, message: stderr)
      end

      # TODO it may have multiple pattern like illegal path, precondition error, enable and disable the same linter at the same time etc..
      # TODO read code for golangci-lint
      if status.exitstatus == 3
        if stderr.include?("must enable at least one")
          return Results::Failure.new(guid: guid, analyzer: analyzer, message: "Must enable at least one linter")
        end

        if stderr.include?("can't be disabled and enabled at one moment")
          return Results::Failure.new(guid: guid, analyzer: analyzer, message: "Can't be disabled and enabled at one moment")
        end

        if stderr.include?("can't combine options --disable-all and --disable")
          return Results::Failure.new(guid: guid, analyzer: analyzer, message: "can't combine options --disable-all and --disable")
        end

        if stderr.include?("only next presets exist")
          return Results::Failure.new(guid: guid, analyzer: analyzer, message: "Only next presets exist: (bugs|complexity|format|performance|style|unused)")
        end

        if stderr.include?("no such linter")
          return Results::Failure.new(guid: guid, analyzer: analyzer, message: "No such linter")
        end
        return Results::Failure.new(guid: guid, analyzer: analyzer, message: "Running error")
      end

      if status.exitstatus == 4 && stderr.include?("Timeout exceeded")
        return Results::Failure.new(guid: guid, analyzer: analyzer, message: "Timeout exceeded: try increase it by passing --timeout option")
      end

      if status.exitstatus == 5 && stderr.include?("no go files to analyze")
        return Results::Failure.new(guid: guid, analyzer: analyzer, message: "No go files to analyze")
      end

      # `6` will be returned when execute 'golangci-lint config path.
      if status.exitstatus == 6
        return Results::Failure.new(guid: guid, analyzer: analyzer, message: stderr)
      end

      if status.exitstatus == 7
        Results::Failure.new(guid: guid, analyzer: analyzer, message: stderr)
      end

      Results::Failure.new(guid: guid, analyzer: analyzer, message: stderr)
    end

    def config
      @config or raise "Must be initialized!"
    end

    def analyzer_options
      [].tap do |opts|
        analysis_targets.each do |target|
          opts << target
        end
        opts << "--out-format=json"
        opts << "--tests=false" if config[:tests] == false
        opts << "--config=#{config[:config]}" if config[:config]
        opts << "--timeout=#{config[:timeout]}" if config[:timeout]

        Array(config[:disable]).each do |disable|
          opts << "--disable=#{disable}"
        end
        Array(config[:enable]).each do |enable|
          opts << "--enable=#{enable}"
        end
        Array(config[:presets]).each do |preset|
          opts << "--presets=#{preset}"
        end

        opts << "--disable-all" if config[:'disable-all']
        opts << "--uniq-by-line=false" if config[:'uniq-by-line'] == false
      end
    end

    def analysis_targets
      if config[:target]
        Array(config[:target])
      else
        Dir.glob(DEFAULT_TARGET, File::FNM_EXTGLOB, base: current_dir)
      end
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
      JSON.parse(stdout, symbolize_names: true)[:Issues].map do |file|
        path = relative_path(file[:Pos][:Filename])

        line = file[:Pos][:Line]
        id = file[:FromLinter]

        Issue.new(
          path: path,
          location: Location.new(start_line: line),
          id: id,
          message: file[:Text],
          links: [],
        )
      end
    end
  end
end
