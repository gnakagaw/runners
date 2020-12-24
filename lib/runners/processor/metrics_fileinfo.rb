module Runners
  class Processor::MetricsFileInfo < Processor
    Schema = _ = StrongJSON.new do


    end

    def extract_version_option
      "-v"
    end

    def setup
      add_warning_if_deprecated_options
      add_warning_for_deprecated_option :targets, to: :target
      yield
    end

    def analyze(_changes)

    end

    private
    #stub

  end
end
