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
  attr_accessor :change_precision
  attr_accessor :report_print_limit
  attr_accessor :report_print_sort_by

  def tmp_directory
    @tmp_directory || Pathname.new(Dir.getwd).join('tmp')
  end

  def output_directory
    @output_directory || Pathname.new(Dir.getwd).join('tmp')
  end

  def change_precision
    @change_precision || 5
  end

  def report_print_limit
    @report_print_limit || 5
  end

  def report_print_sort_by(data)
    (@report_print_sort_by || Proc.new{ |d| d[:max] * -1 }).call(data)
  end

  def finish_time
    @finish_time ||= Time.now.to_i.to_s
  end

  module_function
  def start
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

    reports = ::PigCi::Engine::Rails.reports
    puts "[PigCi] Saving your reports…"
    reports.collect(&:save!)
    puts "[PigCi] Printing your reports…"
    reports.collect(&:print!)
    puts "[PigCi] Sharing your reports…"
  end
end

PigCi.report_print_sort_by = Proc.new { |d| d[:max_change_percentage] * -1 }

at_exit do
  # If we are in a different process than called start, don't interfere.
  next if PigCi.pid != Process.pid

  PigCi.run_exit_tasks! unless $ERROR_INFO
end
