require 'get_process_mem'

class PigCi::Loggers::Memory < PigCi::Loggers
  def self.start!
    GC.disable
  end

  def self.complete!
    GC.enable
  end

  def self.log_value
    ::GetProcessMem.new.kb
  end
end
