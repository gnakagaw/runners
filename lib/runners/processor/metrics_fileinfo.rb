module Runners
  class Processor::MetricsFileInfo < Processor
    Schema = _ = StrongJSON.new do
      let :runner_config, Schema::BaseConfig.base
      let :issue, object(
          line_of_code: integer,
          last_commit_datetime: string
      )
    end

    def analyzer_version
      stdout, _, _ = capture3!("wc", "--version")
      stdout.split(/\R/)[0][/\d*\.\d*/]
    end

    # This analyser use git metadata (.git/).
    def use_git_metadata_dir?
      true
    end

    def analyze(_changes)
      target_files = generate_file_list
      Results::Success.new(
          guid: guid,
          analyzer: analyzer,
          issues: [
              Issue.new(
                  path: relative_path("hello.rb"),
                  location: nil,
                  id: "metrics_fileinfo",
                  message: "hello.rb: loc = 7, last commit datetime = 2020-01-01T10:00:00+09:00",
                  object: {
                      line_of_code: 10,
                      last_commit_datetime: "2020-01-01T10:00:00+09:00"
                  },
                  schema: Schema.issue,
                  )
          ]
      )
    end

    private

    def generate_file_list
      Dir.glob("**/*", File::FNM_DOTMATCH).reject { |e| File.directory? e or e.start_with? ".git/" }
    end

    def analyze_line_of_code(target_files)

    end

  end
end
