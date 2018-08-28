require 'pig_ci/version'
require 'pig_ci/api'
require 'pig_ci/engine'
require 'pig_ci/profiler'
require 'pig_ci/report'

module PigCi

  extend self

  attr_accessor :running
  attr_accessor :pid
  attr_accessor :tmp_directory
  attr_accessor :output_directory
  attr_accessor :finish_time

  module_function
  def start
    self.tmp_directory = Pathname.new(Dir.getwd).join('tmp')
    self.output_directory = Pathname.new(Dir.getwd).join('tmp')
    self.running = true
    self.pid = Process.pid
    puts '[PigCi] Starting up'

    # Add our translations
    I18n.load_path += Dir["#{File.expand_path("../../config/locales/pig_ci", __FILE__)}/*.{rb,yml}"]
    
    # Purge any previous logs and attach some listeners
    ::PigCi::Engine::Rails.setup!
  end

  def run_exit_tasks!
    puts '[PigCI] Finished, expect an output or something in a moment'

    self.finish_time = Time.now.to_i.to_s

    reports = ::PigCi::Engine::Rails.reports
    puts "[PigCi] Saving your reports…"
    reports.collect(&:save!)
    puts "[PigCi] Saving your reports…"
    reports.collect(&:print!)
    puts "[PigCi] Sharing your reports…"
  end
end

PigCi.tmp_directory = Pathname.new(Dir.getwd).join('tmp')
PigCi.output_directory = Pathname.new(Dir.getwd).join('tmp')

at_exit do
  # If we are in a different process than called start, don't interfere.
  next if PigCi.pid != Process.pid

  PigCi.run_exit_tasks! unless $ERROR_INFO
end
