module Runners
  module Python
    def show_runtime_versions
      capture3! "python", "--version"
      capture3! "pip", "--version"
    end
  end
end
