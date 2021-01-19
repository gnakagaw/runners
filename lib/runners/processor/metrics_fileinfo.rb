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

    def analyze(changes)
      Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
        changes.changed_paths.each do |path|
          result.add_issue(generate_issue(path, analyze_line_of_code(path), analyze_last_commit_datetime(path)))
        end
      end
    end

    private

    def generate_issue(path, loc, commit_datetime)
      Issue.new(
        path: relative_path(path),
        location: nil,
        id: "metrics_fileinfo",
        message: "#{path_str(path)}: loc = #{loc}, last commit datetime = #{commit_datetime}",
        object: {
          line_of_code: loc,
          last_commit_datetime: commit_datetime
        },
        schema: Schema.issue
      )
    end

    def analyze_line_of_code(path)
      is_text_file?(path) ? capture3!("wc", "-l", path_str(path)).then {|stdout,| Integer(stdout.split(" ")[0])} : nil
    end

    def analyze_last_commit_datetime(path)
      capture3!("git", "log", "-1", "--format=format:%aI", path_str(path)).then {|stdout,| stdout}
    end

    def is_text_file?(path)
      capture3!("git", "ls-files", "--eol", "--error-unmatch", path_str(path)).then do |stdout, _, _|
        stdout.split(" ")[1].match?("w/-text") ? false : true
      end
    end

    def path_str(path)
      relative_path(path).to_s
    end
  end
end
