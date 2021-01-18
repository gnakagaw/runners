module Runners
  class Processor::MetricsFileInfo < Processor
    Schema = _ = StrongJSON.new do
      # @type self: SchemaClass

      let :runner_config, Schema::BaseConfig.base
      let :issue, object(
          line_of_code: integer?,
          last_commit_datetime: string
      )
    end

    FILE_COMMAND_VALID_PLAIN_TEXT_FORMATS = ["ASCII text", "UTF-8 Unicode text", "ISO-8859 text"].freeze

    def analyzer_version
      @analyzer_version ||= capture3!("wc", "--version").then do |stdout, |
        stdout.split(/\R/)[0][/\d*\.\d*/].then {|ver| ver.nil? ? "unknown" : ver}
      end
    end

    # This analyser use git metadata (.git/).
    def use_git_metadata_dir?
      true
    end

    def analyze(_changes)
      target_files = generate_file_list
      loc = analyze_line_of_code(target_files)
      last_commit_datetime = analyze_last_commit_datetime(target_files)

      Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
        generate_issues(loc, last_commit_datetime).each { |issue| result.add_issue(issue) }
      end
    end

    private

    def generate_file_list
      Dir.glob("**/*", File::FNM_DOTMATCH).reject { |e| File.directory? e or e.start_with? ".git/" }
    end

    def generate_issues(loc_info, commit_datetime_info)
      loc_info.map do |fname, loc|
        commit_datetime = commit_datetime_info[fname]
        Issue.new(
            path: relative_path(fname),
            location: nil,
            id: "metrics_fileinfo",
            message: "#{fname}: loc = #{loc}, last commit datetime = #{commit_datetime}",
            object: {
                line_of_code: loc,
                last_commit_datetime: commit_datetime
            },
            schema: Schema.issue,
            )
      end
    end

    def analyze_line_of_code(target_files)
      target_files.map do |file|
        if is_text_file?(file)
          capture3!("wc", "-l", file).then { |stdout, | [file, stdout.split(" ")[0].to_i]}
        else
          [file, nil]
        end
      end.to_h
    end

    def analyze_last_commit_datetime(target_files)
      target_files.map do |file|
        stdout, _, _  = capture3!("git", "log", "-1", "--format=format:%aI", file)
        [file, stdout]
      end.to_h
    end

    def is_text_file?(target_file)
      stdout, _, _ = capture3!("file", "-E", "-b", target_file)
      stdout.split(",").any? do |type|
        FILE_COMMAND_VALID_PLAIN_TEXT_FORMATS.any? { |t| type.include?(t) }
      end
    end
  end
end
