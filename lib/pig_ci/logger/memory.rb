require 'get_process_mem'

class PigCi::Logger::Memory < PigCi::Logger
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
