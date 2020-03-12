require_relative 'test_helper'

class NodejsTest < Minitest::Test
  include TestHelper

  Constraint = Runners::Nodejs::Constraint
  Dependency = Runners::Nodejs::Dependency
  DefaultDependencies = Runners::Nodejs::DefaultDependencies
  InvalidDefaultDependencies = Runners::Nodejs::InvalidDefaultDependencies
  ConstraintsNotSatisfied = Runners::Nodejs::ConstraintsNotSatisfied
  NpmInstallFailed = Runners::Nodejs::NpmInstallFailed
  YarnInstallFailed = Runners::Nodejs::YarnInstallFailed

  INSTALL_OPTION_NONE = Runners::Nodejs::INSTALL_OPTION_NONE
  INSTALL_OPTION_ALL = Runners::Nodejs::INSTALL_OPTION_ALL
  INSTALL_OPTION_PRODUCTION = Runners::Nodejs::INSTALL_OPTION_PRODUCTION
  INSTALL_OPTION_DEVELOPMENT = Runners::Nodejs::INSTALL_OPTION_DEVELOPMENT

  def processor_class
    @processor_class ||= Class.new(Runners::Processor) do
      include Runners::Nodejs

      def analyzer_bin
        "eslint"
      end
    end
  end

  def trace_writer
    @trace_writer ||= Runners::TraceWriter.new(writer: [])
  end

  def actual_commands
    trace_writer.writer.map { |entry| entry[:command_line] }.compact
  end

  def actual_errors
    trace_writer.writer.select { |entry| entry[:trace] == :error }.map { |entry| entry[:message] }
  end

  def assert_warning_count(expected)
    assert_equal expected, processor.warnings.size
  end

  def assert_warnings(expected)
    assert_equal expected, processor.warnings
  end

  def processor
    @processor
  end

  def new_processor(workspace:)
    @processor = processor_class.new(
      guid: SecureRandom.uuid,
      workspace: workspace,
      config: config,
      git_ssh_path: nil,
      trace_writer: trace_writer,
    )
  end

  def stub_const(name, value)
    begin
      saved_value = Runners::Nodejs.const_get(name)
      silence_warnings { Runners::Nodejs.const_set(name, value) }
      yield
    ensure
      silence_warnings { Runners::Nodejs.const_set(name, saved_value) }
    end
  end

  def test_nodejs_analyzer_local_command
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      assert_equal "node_modules/.bin/eslint", processor.nodejs_analyzer_local_command
    end
  end

  def test_nodejs_analyzer_bin
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      assert_equal "eslint", processor.nodejs_analyzer_bin

      (workspace.working_dir / "node_modules/.bin").mkpath
      (workspace.working_dir / "node_modules/.bin/eslint").write("")
      assert_equal "node_modules/.bin/eslint", processor.nodejs_analyzer_bin
    end
  end

  def test_analyzer_version_with_global
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.stub :nodejs_analyzer_locally_installed?, false do
        processor.stub :nodejs_analyzer_global_version, "1.0.0" do
          assert_equal "1.0.0", processor.analyzer_version
        end
      end
    end
  end

  def test_analyzer_version_with_local
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.stub :nodejs_analyzer_locally_installed?, true do
        processor.stub :nodejs_analyzer_local_version, "2.0.0" do
          assert_equal "2.0.0", processor.analyzer_version
        end
      end
    end
  end

  def test_package_json_path
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      assert_equal(workspace.working_dir / "package.json", processor.package_json_path)
    end
  end

  def test_package_json
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      assert_raises Errno::ENOENT do
        processor.package_json
      end

      (workspace.working_dir / "package.json").write(JSON.generate(name: "foo", version: "1.0.0", number: 999, bool: false))
      assert_equal({ name: "foo", version: "1.0.0", number: 999, bool: false }, processor.package_json)
    end
  end

  def test_package_lock_json_path
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      assert_equal(workspace.working_dir / "package-lock.json", processor.package_lock_json_path)
    end
  end

  def test_yarn_lock_path
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      assert_equal(workspace.working_dir / "yarn.lock", processor.yarn_lock_path)
    end
  end

  def test_install_nodejs_deps
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write(JSON.generate(devDependencies: {
        "eslint" => "5.0.0", "eslint-plugin-react" => "7.10.0"
      }))
      defaults = DefaultDependencies.new(
        main: Dependency.new(name: "eslint", version: "5.15.0"),
        extras: [
          Dependency.new(name: "eslint-plugin-react", version: "7.14.2"),
        ],
      )
      constraints = {
        "eslint" => Constraint.new(">= 5.0.0", "< 7.0.0"),
        "eslint-plugin-react" => Constraint.new(">= 4.2.1", "< 8.0.0"),
      }

      processor.stub :nodejs_analyzer_global_version, "5.15.0" do
        processor.install_nodejs_deps(defaults, constraints: constraints, install_option: INSTALL_OPTION_ALL)

        stdout, _ = processor.capture3!(processor.nodejs_analyzer_bin, "-v")
        assert_equal "v5.0.0\n", stdout
        assert_warning_count 0
      end
    end
  end

  def test_install_nodejs_deps_without_package_json
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      defaults = DefaultDependencies.new(main: Dependency.new(name: "eslint", version: "5.15.0"))
      constraints = { "eslint" => Constraint.new(">= 5.0.0", "< 7.0.0") }

      processor.stub :nodejs_analyzer_global_version, defaults.main.version do
        processor.install_nodejs_deps(defaults, constraints: constraints, install_option: INSTALL_OPTION_ALL)

        assert_warnings [{ message: <<~MSG.strip, file: "package.json" }]
          The `npm_install` option is specified in your `sider.yml`, but a `package.json` file is not found in the repository.
          In this case, any npm packages are not installed.
        MSG
      end
    end
  end

  def test_install_nodejs_deps_with_option_nil_and_without_package_json
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      defaults = DefaultDependencies.new(main: Dependency.new(name: "eslint", version: "5.15.0"))
      constraints = { "eslint" => Constraint.new(">= 5.0.0", "< 7.0.0") }

      processor.stub :nodejs_analyzer_global_version, "5.15.0" do
        processor.install_nodejs_deps(defaults, constraints: constraints, install_option: nil)

        refute processor.package_json_path.exist?
        assert_equal "5.15.0", processor.analyzer_version
        assert_warning_count 0
        assert_equal [], trace_writer.writer.filter { |e| e.key? :command_line }
      end
    end
  end

  def test_install_nodejs_deps_with_option_nil_and_with_package_json
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write(JSON.generate(dependencies: { "eslint" => "6.0.0" }))
      defaults = DefaultDependencies.new(main: Dependency.new(name: "eslint", version: "5.15.0"))
      constraints = { "eslint" => Constraint.new(">= 5.0.0", "< 7.0.0") }

      processor.stub :nodejs_analyzer_global_version, "5.15.0" do
        processor.install_nodejs_deps(defaults, constraints: constraints, install_option: nil)

        assert processor.package_json_path.exist?
        assert_equal "6.0.0", processor.analyzer_version
        assert_warning_count 0
      end
    end
  end

  def test_install_nodejs_deps_with_option_none_and_without_package_json
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      defaults = DefaultDependencies.new(main: Dependency.new(name: "eslint", version: "5.15.0"))
      constraints = { "eslint" => Constraint.new(">= 5.0.0", "< 7.0.0") }

      processor.stub :nodejs_analyzer_global_version, "5.15.0" do
        processor.install_nodejs_deps(defaults, constraints: constraints, install_option: INSTALL_OPTION_NONE)

        refute processor.package_json_path.exist?
        assert_equal "5.15.0", processor.analyzer_version
        assert_warning_count 0
      end
    end
  end

  def test_install_nodejs_deps_with_option_none_and_with_package_json
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write(JSON.generate(dependencies: { "eslint" => "6.0.0" }))
      defaults = DefaultDependencies.new(main: Dependency.new(name: "eslint", version: "5.15.0"))
      constraints = { "eslint" => Constraint.new(">= 5.0.0", "< 7.0.0") }

      processor.stub :nodejs_analyzer_global_version, "5.15.0" do
        processor.install_nodejs_deps(defaults, constraints: constraints, install_option: INSTALL_OPTION_NONE)

        assert processor.package_json_path.exist?
        assert_equal "5.15.0", processor.analyzer_version
        assert_warning_count 0
      end
    end
  end

  def test_install_nodejs_deps_using_yarn
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write(JSON.generate(dependencies: { "eslint" => "6.0.1" }))
      FileUtils.cp data("yarn.lock"), processor.yarn_lock_path

      defaults = DefaultDependencies.new(main: Dependency.new(name: "eslint", version: "5.15.0"))
      constraints = { "eslint" => Constraint.new(">= 5.0.0", "< 7.0.0") }

      processor.stub :nodejs_analyzer_global_version, "5.15.0" do
        processor.install_nodejs_deps(defaults, constraints: constraints, install_option: INSTALL_OPTION_ALL)

        stdout, _ = processor.capture3!(processor.nodejs_analyzer_bin, "-v")
        assert_equal "v6.0.1\n", stdout
        assert_warning_count 0
      end
    end
  end

  def test_install_nodejs_deps_with_duplicate_lockfiles
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write(JSON.generate(dependencies: { "eslint" => "6.0.1" }))
      FileUtils.cp data("yarn.lock"), processor.yarn_lock_path
      FileUtils.cp data("package-lock.json"), processor.package_lock_json_path

      defaults = DefaultDependencies.new(main: Dependency.new(name: "eslint", version: "5.15.0"))
      constraints = { "eslint" => Constraint.new(">= 5.0.0", "< 7.0.0") }

      processor.stub :nodejs_analyzer_global_version, "5.15.0" do
        processor.install_nodejs_deps(defaults, constraints: constraints, install_option: INSTALL_OPTION_ALL)

        stdout, _ = processor.capture3!(processor.nodejs_analyzer_bin, "-v")
        assert_equal "v6.0.1\n", stdout

        assert_warnings [{ message: <<~MSG.strip, file: "yarn.lock" }]
          Two lock files `package-lock.json` and `yarn.lock` are found. Sider uses `yarn.lock` in this case, but please consider deleting either file for more accurate analysis.
        MSG
      end
    end
  end

  def test_check_nodejs_default_deps
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      defaults = DefaultDependencies.new(
        main: Dependency.new(name: "eslint", version: "5.15.0"),
      )

      processor.stub :nodejs_analyzer_global_version, "5.15.0" do
        processor.send(:check_nodejs_default_deps, defaults, {})
        pass "with an empty constraint"

        constraints = { "eslint" => Constraint.new(">= 5.0.0", "< 7.0.0") }
        processor.send(:check_nodejs_default_deps, defaults, constraints)
        pass "with a range constraint"

        constraints = { "eslint" => Constraint.new(">= 5.15.0") }
        processor.send(:check_nodejs_default_deps, defaults, constraints)
        pass "with a minimum constraint"

        constraints = { "eslint" => Constraint.new("<= 5.15.0") }
        processor.send(:check_nodejs_default_deps, defaults, constraints)
        pass "with a maximum constraint"

        constraints = { "eslint" => Constraint.new("= 5.15.0") }
        processor.send(:check_nodejs_default_deps, defaults, constraints)
        pass "with a equal constraint"

        constraints = { "eslint" => Constraint.new("> 5.15.0") }
        error = assert_raises InvalidDefaultDependencies do
          processor.send(:check_nodejs_default_deps, defaults, constraints)
        end
        assert_equal "The default dependency `eslint@5.15.0` must satisfy the constraint `> 5.15.0`", error.message

        constraints = { "eslint" => Constraint.new(">= 5.0.0", "< 5.15.0") }
        error = assert_raises InvalidDefaultDependencies do
          processor.send(:check_nodejs_default_deps, defaults, constraints)
        end
        assert_equal "The default dependency `eslint@5.15.0` must satisfy the constraint `>= 5.0.0, < 5.15.0`", error.message
      end

      processor.stub :nodejs_analyzer_global_version, "1.0.0" do
        error = assert_raises InvalidDefaultDependencies do
          processor.send(:check_nodejs_default_deps, defaults, { "eslint" => Constraint.new("= 5.15.0") })
        end
        assert_equal "The default dependency `eslint` version must be `5.15.0`, but actually `1.0.0`", error.message
      end
    end
  end

  def test_npm_install
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      node_modules = workspace.working_dir / "node_modules"
      typescript = node_modules / "typescript"

      package_json = {
        dependencies: { "typescript" => "3.5.3" },
        scripts: { "postinstall" => "exit 1" },
        engines: { "node" => "8.0.0" },
      }
      processor.package_json_path.write(JSON.generate(package_json))
      (workspace.working_dir / ".npmrc").write("engine-strict = true")

      processor.send(:npm_install, INSTALL_OPTION_NONE)
      refute node_modules.exist?

      processor.send(:npm_install, INSTALL_OPTION_ALL)
      assert typescript.exist?

      node_modules.rmtree
      processor.send(:npm_install, INSTALL_OPTION_PRODUCTION)
      assert typescript.exist?

      node_modules.rmtree
      processor.send(:npm_install, INSTALL_OPTION_DEVELOPMENT)
      refute node_modules.exist?

      processor.package_json_path.write(JSON.generate(devDependencies: { "typescript" => "3.5.3" }))
      processor.send(:npm_install, INSTALL_OPTION_DEVELOPMENT)
      assert typescript.exist?

      expected_commands = [
        %w[npm install --ignore-scripts --progress=false --engine-strict=false --package-lock=false],
        %w[npm install --ignore-scripts --progress=false --engine-strict=false --package-lock=false --only=production],
        %w[npm install --ignore-scripts --progress=false --engine-strict=false --package-lock=false --only=development],
        %w[npm install --ignore-scripts --progress=false --engine-strict=false --package-lock=false --only=development],
      ]
      assert_equal expected_commands, actual_commands
    end
  end

  def test_npm_install_using_ci
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      node_modules = workspace.working_dir / "node_modules"
      typescript = node_modules / "typescript"

      processor.package_json_path.write(JSON.generate(dependencies: { "typescript" => "3.5.3" }))
      FileUtils.cp data("package-lock.json"), processor.package_lock_json_path

      processor.send(:npm_install, INSTALL_OPTION_ALL)
      assert typescript.exist?

      node_modules.rmtree
      processor.send(:npm_install, INSTALL_OPTION_PRODUCTION)
      assert typescript.exist?

      node_modules.rmtree
      processor.send(:npm_install, INSTALL_OPTION_DEVELOPMENT)
      refute typescript.exist?

      processor.package_json_path.write(JSON.generate(devDependencies: { "typescript" => "3.5.3" }))
      FileUtils.cp data("package-lock.dev.json"), processor.package_lock_json_path

      processor.send(:npm_install, INSTALL_OPTION_ALL)
      assert typescript.exist?

      node_modules.rmtree
      processor.send(:npm_install, INSTALL_OPTION_PRODUCTION)
      refute typescript.exist?

      processor.send(:npm_install, INSTALL_OPTION_DEVELOPMENT)
      assert typescript.exist?

      expected_commands = [
        %w[npm ci --ignore-scripts --progress=false --engine-strict=false],
        %w[npm ci --ignore-scripts --progress=false --engine-strict=false --only=production],
        %w[npm install --ignore-scripts --progress=false --engine-strict=false --only=development --package-lock=false],
        %w[npm ci --ignore-scripts --progress=false --engine-strict=false],
        %w[npm ci --ignore-scripts --progress=false --engine-strict=false --only=production],
        %w[npm install --ignore-scripts --progress=false --engine-strict=false --only=development --package-lock=false],
      ]
      assert_equal expected_commands, actual_commands

      expected_warning = { message: <<~MSG.strip, file: "package.json" }
        The `npm ci --only=development` command does not install anything, so `npm install --only=development` will be used instead.
        If you want to use `npm ci`, please change your install option from `development` to `true`.
        For details about the npm behavior, see https://npm.community/t/npm-ci-only-dev-does-not-install-anything/3068
      MSG
      assert_warnings [expected_warning, expected_warning]
    end
  end

  def test_npm_install_failed
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write(JSON.generate(dependencies: { "foo" => "github:sider/foo" }))

      error = assert_raises NpmInstallFailed do
        processor.send(:npm_install, INSTALL_OPTION_ALL)
      end
      expected_error_message = <<~MSG.strip
        `npm install` failed. Please check the log for details.
        If you want to explicitly disable the installation, please set `npm_install: false` on your `sider.yml`.
      MSG
      assert_equal expected_error_message, error.message
      assert_equal [expected_error_message], actual_errors
    end
  end

  def test_yarn_install
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      node_modules = workspace.working_dir / "node_modules"
      eslint = node_modules / "eslint"

      processor.package_json_path.write(JSON.generate(dependencies: { "eslint" => "6.0.1" }))
      FileUtils.cp data("yarn.lock"), processor.yarn_lock_path

      processor.send(:yarn_install, INSTALL_OPTION_NONE)
      refute eslint.exist?

      processor.send(:yarn_install, INSTALL_OPTION_ALL)
      assert eslint.exist?

      eslint.rmtree
      processor.send(:yarn_install, INSTALL_OPTION_PRODUCTION)
      assert eslint.exist?

      node_modules.rmtree
      processor.send(:yarn_install, INSTALL_OPTION_DEVELOPMENT)
      assert eslint.exist?

      expected_commands = [
        %w[yarn install --ignore-engines --ignore-scripts --no-progress --non-interactive --frozen-lockfile],
        %w[yarn install --ignore-engines --ignore-scripts --no-progress --non-interactive --frozen-lockfile --production],
        %w[yarn install --ignore-engines --ignore-scripts --no-progress --non-interactive --frozen-lockfile],
      ]
      assert_equal expected_commands, actual_commands

      expected_warning = <<~MSG.strip
        Yarn does not have a same feature as `npm install --only=development`, so the option `development` will be ignored.
        See https://github.com/yarnpkg/yarn/issues/3254 for details.
      MSG
      actual_warnings = trace_writer.writer.select { |e| e[:trace] == :warning }.map { |e| e[:message] }
      assert_equal [expected_warning], actual_warnings
      assert_equal [{ message: expected_warning, file: "yarn.lock" }], processor.warnings
    end
  end

  def test_yarn_install_failed
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      # 'yarn install' fails because of incorrect package settings between yarn.lock and package.json
      FileUtils.cp incorrect_yarn_data("yarn.lock"), processor.yarn_lock_path
      FileUtils.cp incorrect_yarn_data("package.json"), processor.package_json_path

      error = assert_raises YarnInstallFailed do
        processor.send(:yarn_install, INSTALL_OPTION_ALL)
      end
      expected_error_message = <<~MSG.strip
        `yarn install` failed. Please confirm `yarn.lock` is consistent with `package.json`.
      MSG
      assert_equal expected_error_message, error.message
      assert_equal [expected_error_message], actual_errors
    end
  end

  def test_list_installed_nodejs_deps
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write JSON.generate(dependencies: { "is-arguments" => "1.0.0" })
      processor.capture3! "npm", "install"

      assert_equal({ "is-arguments" => "1.0.0" }, processor.send(:list_installed_nodejs_deps))
    end
  end

  def test_list_installed_nodejs_deps_without_version
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write JSON.generate(dependencies: { "is-arguments" => "1.0.0" })

      assert_equal({ "is-arguments" => "" }, processor.send(:list_installed_nodejs_deps))
    end
  end

  def test_list_installed_nodejs_deps_with_only
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write JSON.generate(dependencies: { "is-arguments" => "1.0.0", "isarray" => "2.0.0" })
      processor.capture3! "npm", "install"

      assert_equal({ "isarray" => "2.0.0" }, processor.send(:list_installed_nodejs_deps, only: ["isarray"]))
    end
  end

  def test_list_installed_nodejs_deps_with_chdir
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      another_dir = (workspace.working_dir / "foo").tap(&:mkdir)
      (another_dir / "package.json").write JSON.generate(dependencies: { "isarray" => "1.0.0" })

      assert_equal({ "isarray" => "" }, processor.send(:list_installed_nodejs_deps, chdir: another_dir))
    end
  end

  def test_list_installed_nodejs_deps_without_results
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      processor.package_json_path.write JSON.generate({})

      assert_equal({}, processor.send(:list_installed_nodejs_deps))
    end
  end

  def test_check_installed_nodejs_deps
    with_workspace do |workspace|
      new_processor(workspace: workspace)

      npm_install = ->(json) {
        processor.package_json_path.write(JSON.generate(json))
        processor.send(:npm_install, INSTALL_OPTION_ALL)
      }

      default = Dependency.new(name: "eslint", version: "5.1.0")
      constraints = { "eslint" => Constraint.new(">= 5.0.0") }

      npm_install.call(dependencies: {})
      processor.send(:check_installed_nodejs_deps, constraints, default)
      pass "when no dependencies"

      npm_install.call(dependencies: { "ci-info" => "2.0.0" })
      processor.send(:check_installed_nodejs_deps, constraints, default)
      pass "when no dependencies satisfying constraints"

      expected_error_message = <<~MSG.strip
        Your `eslint` settings could not satisfy the required constraints. Please check your `package.json` again.
        If you want to analyze via the Sider default settings, please configure your `sider.yml`. For details, see the documentation.
      MSG

      npm_install.call(dependencies: { "eslint-config-standard" => "10.0.0" })
      processor.send(:check_installed_nodejs_deps, constraints, default)
      pass expected_error_message

      npm_install.call(dependencies: { "eslint" => "4.0.0" })
      error = assert_raises ConstraintsNotSatisfied do
        processor.send(:check_installed_nodejs_deps, constraints, default)
      end
      assert_equal expected_error_message, error.message

      ### assert warnings output

      expected_warnings = [
        "No required dependencies for analysis were installed. Instead, the pre-installed `eslint@5.1.0` will be used.",
        "The required dependency `eslint` may not have been correctly installed. It may be a missing peer dependency."
      ]
      actual_warnings = trace_writer.writer.select { |e| e[:trace] == :warning }.map { |e| e[:message] }
      assert_equal expected_warnings, actual_warnings
      assert_equal [
        { message: expected_warnings[0], file: "package.json" },
        { message: expected_warnings[1], file: "package.json" },
      ], processor.warnings

      expected_errors = [
        "The installed dependency `eslint@4.0.0` did not satisfy the constraint `>= 5.0.0`.",
        expected_error_message,
      ]
      assert_equal expected_errors, actual_errors
    end
  end
end
