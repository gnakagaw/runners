module Runners
  class Processor::MetricsFileInfo < Processor
    Schema = _ = StrongJSON.new do
      let :runner_config, Schema::BaseConfig.base
      let :issue, object(
          line_of_code: integer,
          last_commit_datetime: string?
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
      loc = analyze_line_of_code(target_files)
      last_commit_date = analyze_last_commit_date(target_files)

      fileinfo = loc.merge(last_commit_date) do |_, loc, last_commit_date|
        { loc: loc, last_commit_date: last_commit_date }
      end

      result = Results::Success.new(guid: guid, analyzer: analyzer)
      fileinfo.each do |file, metrics|
        loc = metrics[:loc]
        commit_date = metrics[:last_commit_date]

        result.add_issue(
            Issue.new(
                path: relative_path(file),
                location: nil,
                id: "metrics_fileinfo",
                message: "hello.rb: loc = #{loc}, last commit datetime = #{commit_date}",
                object: {
                    line_of_code: loc,
                    last_commit_datetime: commit_date
                },
                schema: Schema.issue,
                )
        )
      end
      result
    end

    private

    def generate_file_list
      Dir.glob("**/*", File::FNM_DOTMATCH).reject { |e| File.directory? e or e.start_with? ".git/" }
    end

    def analyze_line_of_code(target_files)
      target_files.map do |file|
        unless is_text_file?(file)
          next [file, nil]
        end
        stdout, _, _ = capture3!("wc", "-l", file)
        loc, _ = stdout.split(" ")
        [file, loc.to_i]
      end.to_h
    end

    def is_text_file?(target_file)
      true
    end

    def analyze_last_commit_date(target_files)
      target_files.map do |file|
        stdout, _, _  = capture3!("git", "log", "-1", "--format=format:%aI", file)
        [file, stdout]
      end.to_h
    end
  end
end
