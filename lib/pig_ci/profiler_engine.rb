class PigCI::ProfilerEngine
  attr_accessor :request_key, :profilers, :reports, :request_captured

  def initialize(profilers: nil, reports: nil)
    @profilers = profilers || []
    @reports = reports || []
    @request_captured = false
  end

  def request_key?
    !@request_key.nil? && @request_key != ""
  end

  def request_captured?
    @request_captured
  end

  def request_captured!
    @request_captured = true
  end

  def setup!
    Dir.mkdir(PigCI.tmp_directory) unless File.exist?(PigCI.tmp_directory)

    yield if block_given?

    profilers.collect(&:setup!)

    # Attach listeners to the rails events.
    attach_listeners!
  end

  private

  def attach_listeners!
    raise NotImplementedError
  end
end

require "pig_ci/profiler_engine/rails"
