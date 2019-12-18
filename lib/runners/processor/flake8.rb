module Runners
  class Processor::Flake8 < Processor
    include Python

    FLAKE8_OUTPUT_FORMAT = '%(code)s:::%(path)s:::%(row)d:::%(col)d:::%(text)s'.freeze

    Schema = StrongJSON.new do
      let :runner_config, Schema::RunnerConfig.base.update_fields { |fields|
        fields.merge!({
                        version: numeric?,
                        plugins: enum?(string, array(string))
                      })
      }
    end

    def self.ci_config_section_name
      'flake8'
    end

    def analyzer_name
      'Flake8'
    end

    def setup
      prepare_config
      yield
    end

    def analyze(changes)
      ensure_runner_config_schema(Schema.runner_config) do |config|
        set_python2 if use_python2?(config)
        unset_pyenv_local
        show_python_runtime_versions
        prepare_plugins(config)
        run_analyzer
      end
    end

    def show_runtime_versions
      # NOTE: Prevent such error: "pyenv: version `2.7.0' is not installed"
    end

    def show_python_runtime_versions
      capture3! "python", "--version"
      capture3! "pip", "--version"
    end

    private

    def prepare_config
      default_config = (Pathname(Dir.home) / '.config/flake8').realpath
      return default_config.delete if (current_dir / '.flake8').exist?
      configs = %w[setup.cfg tox.ini].select do |v|
        path = (current_dir + v)
        path.exist? && path.read.match(/^\[flake8\]$/m)
      end
      return default_config.delete unless configs.empty?
    end

    def prepare_plugins(config)
      if config[:plugins]
        plugins = Array(config[:plugins]).flatten
        capture3!('pip', 'install', '--user', *plugins)
      end
    end

    def use_python2?(config)
      if config[:version]&.to_i == 2
        return true
      end

      dot_python_version = current_dir / '.python-version'
      if dot_python_version.exist? && dot_python_version.read.start_with?('2')
        trace_writer.message '".python-version" file is detected. Use Python 2.'
        return true
      end

      false
    end

    def set_python2
      capture3! "pyenv", "global", ENV.fetch("PYTHON2_VERSION")
    end

    # NOTE: Prevent pyenv local setting's effect.
    def unset_pyenv_local
      capture3! "pyenv", "local", "--unset"
    end

    def ignored_config_path
      (Pathname(Dir.home) / '.config/ignored-config.ini').realpath
    end

    def parse_result(output)
      # Output example:
      #
      # E999:::app1/views.py:::6:::12:::IndentationError: unexpected indent
      #
      # `:::` is a separater
      #
      output.split("\n").map do |value|
        id, path, line, _, message = value.split(':::')
        loc = Location.new(
          start_line: line.to_i,
          start_column: nil,
          end_line: nil,
          end_column: nil
        )
        Issue.new(
          path: relative_path(path),
          location: loc,
          id: id,
          message: message,
        )
      end.compact
    end

    def run_analyzer
      Results::Success.new(guid: guid, analyzer: analyzer).tap do |result|
        output = Dir.mktmpdir do |tmpdir|
          output_path = Pathname(tmpdir) + 'output.txt'
          capture3!(
            analyzer_bin,
            '--exit-zero',
            "--output-file=#{output_path}",
            "--format=#{FLAKE8_OUTPUT_FORMAT}",
            "--append-config=#{ignored_config_path}",
            './'
          )
          output_path.read
        end
        break result if output.empty?
        trace_writer.message output
        parse_result(output).each { |v| result.add_issue(v) }
      end
    end
  end
end
