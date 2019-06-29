class PigCI::ProfilerEngine
  class << self
    attr_accessor :request_key
  end
end

require 'pig_ci/profiler_engine/rails'
