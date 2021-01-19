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
      @analyzer_version ||= extract_version!("wc")
    end

    # This analyser use git metadata (.git/).
    def use_git_metadata_dir?
      true
    end

    def analyze(_changes)
      target_files = generate_file_list

      Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
        target_files.each do |file|
          result.add_issue(generate_issue(file, analyze_line_of_code(file), analyze_last_commit_datetime(file)))
        end
      end
    end

    private

    def generate_file_list
      Dir.glob("**/*", File::FNM_DOTMATCH).reject { |e| File.directory? e or e.start_with? ".git/" }
    end

    def generate_issue(file, loc, commit_datetime)
      Issue.new(
        path: relative_path(file),
        location: nil,
        id: "metrics_fileinfo",
        message: "#{file}: loc = #{loc}, last commit datetime = #{commit_datetime}",
        object: {
          line_of_code: loc,
          last_commit_datetime: commit_datetime
        },
        schema: Schema.issue
      )
    end

    def analyze_line_of_code(target_file)
      is_text_file?(target_file) ? capture3!("wc", "-l", target_file).then {|stdout,| Integer(stdout.split(" ")[0])} : nil
    end

    def analyze_last_commit_datetime(target_file)
      capture3!("git", "log", "-1", "--format=format:%aI", target_file).then {|stdout,| stdout}
    end

    def is_text_file?(target_file)
      capture3!("git", "ls-files", "--eol", "--error-unmatch", target_file).then do |stdout, _, _|
        stdout.split(" ")[1].match?("w/-text") ? false : true
      end
    end
  end
end
