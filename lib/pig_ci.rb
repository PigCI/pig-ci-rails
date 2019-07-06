# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string/inflections'

require 'pig_ci/version'
require 'pig_ci/api'
require 'pig_ci/decorator'
require 'pig_ci/summary'
require 'pig_ci/profiler_engine'
require 'pig_ci/profiler'
require 'pig_ci/metric'
require 'pig_ci/report'

module PigCI
  extend self

  attr_accessor :pid

  attr_accessor :tmp_directory
  def tmp_directory
    @tmp_directory || Pathname.new(Dir.getwd).join('tmp', 'pig-ci')
  end

  attr_accessor :output_directory
  def output_directory
    @output_directory || Pathname.new(Dir.getwd).join('pig-ci')
  end

  attr_accessor :max_change_percentage_precision
  def max_change_percentage_precision
    @max_change_percentage_precision || 1
  end

  attr_accessor :report_memory_precision
  def report_memory_precision
    @report_memory_precision || 2
  end

  attr_accessor :terminal_report_row_limit
  def terminal_report_row_limit
    @terminal_report_row_limit || -1
  end

  # PigCI.report_row_sort_by = Proc.new { |d| d[:max_change_percentage] * -1 }
  attr_accessor :report_row_sort_by
  def report_row_sort_by(data)
    (@report_row_sort_by || proc { |d| d[:max].to_i * -1 }).call(data)
  end

  attr_accessor :historical_data_run_limit
  def historical_data_run_limit
    @historical_data_run_limit ||= 10
  end

  attr_accessor :run_timestamp
  def run_timestamp
    @run_timestamp ||= Time.now.to_i.to_s
  end

  attr_accessor :profiler_engine
  def profiler_engine
    @profiler_engine ||= PigCI::ProfilerEngine::Rails.new
  end

  attr_accessor :api_base_uri
  def api_base_uri
    @api_base_uri || 'https://api.pigci.com'
  end

  attr_accessor :api_verify_ssl
  def api_verify_ssl
    !@api_verify_ssl.nil? ? @api_verify_ssl : true
  end

  attr_accessor :api_key
  def api_key?
    !@api_key.nil? && @api_key != ''
  end

  attr_accessor :commit_sha1
  def commit_sha1
    @commit_sha1 || ENV['CIRCLE_SHA1'] || ENV['TRAVIS_COMMIT'] || `git rev-parse HEAD`.strip
  end

  attr_accessor :head_branch
  def head_branch
    @head_branch || ENV['CIRCLE_BRANCH'] || ENV['TRAVIS_BRANCH'] || `git rev-parse --abbrev-ref HEAD`.strip
  end

  attr_accessor :locale
  def locale
    @locale || :en
  end

  module_function

  def start(&block)
    self.pid = Process.pid

    block.call(self) if block_given?

    # Add our translations
    load_i18ns!

    # Make sure our directories exist
    Dir.mkdir(tmp_directory) unless File.exist?(tmp_directory)
    Dir.mkdir(output_directory) unless File.exist?(output_directory)

    # Purge any previous logs and attach some listeners
    profiler_engine.setup!
  end

  def load_i18ns!
    I18n.available_locales << PigCI.locale
    I18n.load_path += Dir["#{File.expand_path('../config/locales/pig_ci', __dir__)}/*.{rb,yml}"]
  end

  def run_exit_tasks!
    return if PigCI.pid != Process.pid || !PigCI.profiler_engine.request_captured?

    # Save all the reports as JSON
    profiler_engine.profilers.each(&:save!)

    # Print the report summary to Terminal
    PigCI::Summary::Terminal.new(reports: profiler_engine.reports).print!

    # Save the report summary to the project root.
    PigCI::Summary::HTML.new(reports: profiler_engine.reports).save!

    # If they have an API key, share it with PigCI.com
    PigCI::Api::Reports.new(reports: profiler_engine.reports).share! if PigCI.api_key?
  end
end

at_exit do
  PigCI.run_exit_tasks!
end
