class PigCi::Profiler::InstantiationActiveRecord < PigCi::Profiler
  def self.start!
    @object_count = 0
  end

  def self.increment!(by: 1)
    @object_count += by
  end

  def self.log_value
    @object_count
  end
end
