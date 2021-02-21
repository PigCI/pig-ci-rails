require "get_process_mem"

class PigCI::Profiler::Memory < PigCI::Profiler
  def reset!
    GC.disable
  end

  def log_request!(request_key)
    GC.enable
    super
  end

  def log_value
    ::GetProcessMem.new.bytes
  end
end
