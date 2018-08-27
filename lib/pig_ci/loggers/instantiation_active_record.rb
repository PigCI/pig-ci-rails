class PigCi::Loggers::InstantiationActiveRecord < PigCi::Loggers
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
