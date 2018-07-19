require "pig_ci/version"

module PigCi
  module_function

  attr_accessor :running
  attr_accessor :pid

  def start
    self.running = true
    self.pid = Process.pid

    # Purge any previous logs
    
    # Attach listners
    puts 'running'
  end

  def run_exit_tasks!
    puts 'finished'
  end
end

at_exit do
  # If we are in a different process than called start, don't interfere.
  next if PigCi.pid != Process.pid

  PigCi.run_exit_tasks!
end
