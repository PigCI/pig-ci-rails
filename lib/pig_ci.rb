require "pig_ci/version"
require "pig_ci/rails"

require "pig_ci/loggers"
require "pig_ci/loggers/memory"
require "pig_ci/loggers/sql"

module PigCi

  extend self

  attr_accessor :running
  attr_accessor :pid
  attr_accessor :tmp_directory

  module_function
  def start
    self.tmp_directory = Pathname.new(Dir.getwd).join('tmp')
    self.running = true
    self.pid = Process.pid
    puts '[PigCi] Starting up'

    # Purge any previous logs
    ::PigCi::Rails.purge_previous_snapshots!
    
    # Attach listeners
    ::PigCi::Rails.attach_listeners!
  end

  def run_exit_tasks!
    puts '[PigCI] Finished, expect an output or something in a moment'

    ::PigCi::Rails.build_report!
  end
end

at_exit do
  # If we are in a different process than called start, don't interfere.
  next if PigCi.pid != Process.pid

  PigCi.run_exit_tasks!
end
