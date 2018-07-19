require "pig_ci/version"

module PigCi

  extend self

  attr_accessor :running
  attr_accessor :pid

  module_function
  def start
    self.running = true
    self.pid = Process.pid
    puts '[PigCi] Starting up'

    # Purge any previous logs
    
    # Attach listners
  end

  def run_exit_tasks!
    puts '[PigCI] Finished, expect an output or something in a moment'
  end
end

at_exit do
  # If we are in a different process than called start, don't interfere.
  next if PigCi.pid != Process.pid

  PigCi.run_exit_tasks!
end
