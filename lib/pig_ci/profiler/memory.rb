require 'get_process_mem'

class PigCi::Profiler::Memory < PigCi::Profiler
  def self.start!
    GC.disable
  end

  def self.append_row(key)
    super
    GC.enable
  end

  def self.log_value
    ::GetProcessMem.new.bytes
  end
end
