class PigCI::Profiler::RequestTime < PigCI::Profiler
  attr_accessor :start_time, :end_time

  def reset!
    super
    @start_time = Time.now.utc
  end

  def log_request!(request_key)
    @end_time = Time.now.utc
    super
  end

  def log_value
    (@end_time - @start_time) * 1000.0
  end
end
