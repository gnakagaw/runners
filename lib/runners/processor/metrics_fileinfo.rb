module Runners
  class Processor::MetricsFileInfo < Processor
    Schema = _ = StrongJSON.new do
      # @type self: SchemaClass

      let :runner_config, Schema::BaseConfig.base
      let :issue, object(
        lines_of_code: integer?,
        last_committed_at: string
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
      targets = changes.changed_paths.map { |x| relative_path(x)}
      analyze_last_committed_at(targets)
      analyze_lines_of_code(targets)

      Results::Success.new(
        guid: guid,
        analyzer: analyzer,
        issues: targets.map { |path| generate_issue(path) }
      )
    end

    private

    def generate_issue(path)
      filename = path.to_path
      loc = lines_of_code[filename]
      commit = last_committed_at[filename]

      Issue.new(
        path: path,
        location: nil,
        id: "metrics_fileinfo",
        message: "#{filename}: loc = #{loc}, last commit datetime = #{commit}",
        object: {
          lines_of_code: loc,
          last_committed_at: commit
        },
        schema: Schema.issue
      )
    end

    def lines_of_code
      @lines_of_code ||= {}
    end

    def analyze_lines_of_code(targets)
      text_files = targets.map(&:to_path).select { |f| text_file?(f) }
      text_files.each_slice(1000) do |files|
        stdout, _ = capture3!("wc", "-l", *files)
        lines = stdout.lines(chomp: true).tap do |l|
          # wc command outputs total count when we pass multiple targets. remove it if exist
          last_line = (l.last or break)
          l.pop if last_line.match?(/^\d+ total$/)
        end
        lines.each do |line|
          fields = line.split(" ")
          loc = (fields[0] or raise)
          fname = (fields[1] or raise)
          lines_of_code[fname] = Integer(loc)
        end
      end
    end

    def last_committed_at
      @last_committed_at ||= {}
    end

    def analyze_last_committed_at(targets)
      targets.each do |target|
        path = target.to_path
        stdout, _ = capture3!("git", "log", "-1", "--format=format:%aI", path)
        last_committed_at[path] = stdout
      end
      nil
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
    def text_files
      @text_files ||= Set[].tap do |result|
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

    def text_file?(target)
      text_files.include?(target)
    end
  end
end
