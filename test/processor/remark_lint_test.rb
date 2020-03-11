require "test_helper"

class Runners::Processor::RemarkLintTest < Minitest::Test
  include TestHelper

  def trace_writer
    @trace_writer ||= Runners::TraceWriter.new(writer: [])
  end

  def subject
    @subject
  end

  def setup_subject(workspace)
    @subject = Runners::Processor::RemarkLint.new(
      guid: SecureRandom.uuid,
      workspace: workspace,
      config: config,
      git_ssh_path: nil,
      trace_writer: trace_writer
    ).tap do |s|
      stub(s).analyzer_id { "remark_lint" }
    end
  end

  def test_analyzer_version
    with_workspace do |workspace|
      setup_subject(workspace)

      mock(Dir).home { "" }

      assert_equal ["*.php"], subject.analyzer_version
    end
  end
end
