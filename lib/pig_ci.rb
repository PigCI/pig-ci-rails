require 'pig_ci/version'
require 'pig_ci/api'
require 'pig_ci/profiler_engine'
require 'pig_ci/profiler'
require 'pig_ci/report'

module PigCi

  extend self

  attr_accessor :running
  attr_accessor :pid
  attr_accessor :request_was_completed

  attr_accessor :tmp_directory
  def tmp_directory
    @tmp_directory || Pathname.new(Dir.getwd).join('tmp')
  end

  attr_accessor :output_directory
  def output_directory
    @output_directory || Pathname.new(Dir.getwd).join('tmp')
  end

  attr_accessor :change_precision
  def change_precision
    @change_precision || 5
  end

  attr_accessor :report_print_limit
  def report_print_limit
    @report_print_limit || -1
  end

  attr_accessor :report_print_sort_by
  def report_print_sort_by(data)
    (@report_print_sort_by || Proc.new{ |d| d[:max] * -1 }).call(data)
  end

  attr_accessor :run_timestamp
  def run_timestamp
    @run_timestamp ||= Time.now.to_i.to_s
  end

  attr_accessor :profile_engine
  def profiler_engine
    @profiler_engine ||= PigCi::ProfilerEngine::Rails
  end

  attr_accessor :request_key
  def request_key(payload)
    (@request_key || Proc.new{ |pl| "#{pl[:method]} #{pl[:controller]}##{pl[:action]}{format:#{pl[:format]}}" }).call(payload)
  end

  attr_accessor :api_base_uri
  def api_base_uri
    @api_base_uri || 'https://api.pigci.com/v1'
  end

  attr_accessor :api_verify_ssl
  def api_verify_ssl
    !@api_verify_ssl.nil? ? @api_verify_ssl : true
  end

  attr_accessor :api_key

  attr_accessor :commit_sha1
  def commit_sha1
    @commit_sha1 || ENV['CIRCLE_SHA1'] || ENV['TRAVIS_COMMIT'] || `git rev-parse HEAD`
  end

  attr_accessor :reporter_name
  def reporter_name
    @reporter_name || ('Circle CI' if ENV['CIRCLE_SHA1']) || ('TravisCi' if ENV['TRAVIS_COMMIT'])
  end

  module_function
  def start(&block)
    self.running = true
    self.pid = Process.pid
    puts '[PigCi] Starting up'

    block.call(self) if block_given?

    # Add our translations
    I18n.load_path += Dir["#{File.expand_path("../../config/locales/pig_ci", __FILE__)}/*.{rb,yml}"]
    
    # Purge any previous logs and attach some listeners
    self.profiler_engine.setup!
  end

  def run_exit_tasks!
    puts '[PigCI] Finished, expect an output or something in a moment'

    reports = self.profiler_engine.reports
    puts "[PigCi] Saving your reports…"
    reports.collect(&:save!)
    puts "[PigCi] Printing your reports…\n\n"
    reports.collect(&:print!)
    if PigCi.api_key.present?
      puts "[PigCi] Sharing your reports…"
      PigCi::Api::ShareReports.new(reports: reports).share
    else
      puts "[PigCi] You can share your reports PigCI with your colleagues via https://pigci.com/"
    end
  end
end

# PigCi.report_print_sort_by = Proc.new { |d| d[:max_change_percentage] * -1 }

at_exit do
  # If we are in a different process than called start, don't interfere.
  next if PigCi.pid != Process.pid

  PigCi.run_exit_tasks! if PigCi.request_was_completed
end
