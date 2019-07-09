# frozen_string_literal: true

class PigCI::Profiler::DatabaseObjectInstantiation < PigCI::Profiler
  def increment!(by: 1)
    @log_value += by
  end
end
