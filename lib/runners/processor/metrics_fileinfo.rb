module Runners
  class Processor::MetricsFileInfo < Processor
    Schema = _ = StrongJSON.new do
      # @type self: SchemaClass

      let :runner_config, Schema::BaseConfig.base
      let :issue, object(
        line_of_code: integer?,
        last_commit_datetime: integer
      )
    end

    def analyzer_version
      Runners::VERSION
    end

    # This analyser use git metadata (.git/).
    def use_git_metadata_dir?
      true
    end

    def analyze(changes)
      Results::Success.new(
        guid: guid,
        analyzer: analyzer,
        issues: changes.changed_paths.map { |path| generate_issue(path) }
      )
    end

    private
    def generate_issue(path)
      filepath = relative_path(path)
      loc = text_file?(filepath.to_path) ? analyze_line_of_code(filepath.to_path) : nil
      last_commit_iso, last_commit_epoch = analyze_last_commit_datetime(filepath.to_path)

      Issue.new(
        path: filepath,
        location: nil,
        id: "metrics_fileinfo",
        message: "#{filepath}: loc = #{loc}, last commit datetime = #{last_commit_iso}",
        object: {
          line_of_code: loc,
          last_commit_datetime: Integer(last_commit_epoch)
        },
        schema: Schema.issue
      )
    end

    def analyze_line_of_code(target)
      stdout, _ = capture3!("wc", "-l", target)
      Integer(stdout.split(" ")[0])
    end

    def analyze_last_commit_datetime(target)
      last_commit = capture3!("git", "log", "-1", "--format=format:%aI|%at", target).then { |stdout,| stdout.split("|")}
      [last_commit[0], last_commit[1]]
    end

    def text_file?(target)
      capture3!("git", "ls-files", "--eol", "--error-unmatch", target).then do |stdout, _, _|
        stdout.split(" ")[1].match?("w/-text") ? false : true
      end
    end
  end
end
