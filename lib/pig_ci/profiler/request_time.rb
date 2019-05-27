class PigCi::Profiler::RequestTime < PigCi::Profiler
  def self.start!
    @start_time = Time.zone.now
  end

  def self.stop!
    @end_time = Time.zone.now
  end

  def self.log_value
    (@end_time - @start_time) * 1000.0
  end
end
