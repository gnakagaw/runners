class Runners::Ignoring
  attr_reader workspace: Workspace
  attr_reader ignore_patterns: Array<String>

  def initialize: (workspace: Workspace, ignore_patterns: Array<String>) -> void
  def delete_ignored_files!: () -> Array<String>
end
