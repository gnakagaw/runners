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
      last_commit = analyze_last_commit_datetime(filepath.to_path)

      Issue.new(
        path: filepath,
        location: nil,
        id: "metrics_fileinfo",
        message: "#{filepath}: loc = #{loc}, last commit datetime = #{last_commit}",
        object: {
          line_of_code: loc,
          last_committed_at: last_commit
        },
        schema: Schema.issue
      )
    end

    def analyze_line_of_code(target)
      stdout, _ = capture3!("wc", "-l", target)
      Integer(stdout.split(" ")[0])
    end

    def analyze_last_commit_datetime(target)
      capture3!("git", "log", "-1", "--format=format:%aI", target)[0]
    end

    def text_files
      @text_files ||= search_text_files
    end

    def text_file?(target)
      text_files.include?(target)
    end

    # There may not be a perfect method to discriminate file type.
    # We determined to use 'git ls-file' command with '--eol' option based on an evaluation.
    #  the target methods: mimemagic library, file(1) command, git ls-files --eol.
    #
    # 1. mimemagic library (https://rubygems.org/gems/mimemagic/)
    # Pros:
    #   * A Gem library. We can install easily.
    #   * It seems to be well-maintained now.
    # Cons:
    #   * This library cannot distinguish between a plain text file and a binary file.
    #
    # 2. file(1) command (https://linux.die.net/man/1/file)
    # Pros:
    #   * This is a well-known method to inspect file type.
    # Cons:
    #   * We have to install an additional package on devon_rex_base.
    #   * File type classification for plain text is too detailed. File type string varies based on the target file encoding.
    #     * e.g.  ASCII text, ISO-8859 text, ASCII text with escape sequence, UTF-8 Unicode text, Non-ISO extended-ASCII test, and so on.
    #
    # 3. git ls-files --eol (See: https://git-scm.com/docs/git-ls-files#Documentation/git-ls-files.txt---eol)
    #  Pros:
    #    * We don't need any additional packages.
    #    * It output whether the target file is text or not. (This is the information we need)
    #    * The output is reliable to some extent because Git is a very well maintained and used OSS product.
    #  Cons:
    #    * (no issue found)
    #
    # We've tested some ambiguous cases in binary_files, multi_language, and unknown_extension smoke test cases.
    # We can determine file type correctly in cases as below.
    #  * A plain text file having various extensions (.txt, .rb, .md, etc..)
    #  * A binary file having various extensions (.png, .data, etc...)
    #  * A binary file, but having .txt extension. (e.g. no_text.txt)
    #  * A text files not encoded in UTF-8 but EUC-JP, ISO-2022-JP, Shift JIS.
    #  * A text file having a non-well-known extension. (e.g. foo.my_original_extension )
    def search_text_files
      Set[].tap do |result|
        stdout, _ = capture3!("git", "ls-files", "--eol", "--error-unmatch", trace_stdout: false)
        stdout.each_line(chomp: true) do |line|
          fields = line.split(" ")
          type = (fields[1] or raise)
          file = (fields[3] or raise)
          if type != "w/-text"
            result << file
          end
        end
      end
    end
  end
end
