class PigCi::Profiler::SqlActiveRecord < PigCi::Profiler
  def self.start!
    @query_count = 0
  end

  def self.increment!(by: 1)
    @query_count += by
  end

  def self.log_value
    @query_count
  end
end
