require 'active_support'
require 'active_support/core_ext/string/inflections'

require 'pig_ci/version'
require 'pig_ci/api'
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

  attr_accessor :report_print_limit
  def report_print_limit
    @report_print_limit || -1
  end

  # PigCI.report_print_sort_by = Proc.new { |d| d[:max_change_percentage] * -1 }
  attr_accessor :report_print_sort_by
  def report_print_sort_by(data)
    (@report_print_sort_by || Proc.new { |d| d[:max].to_i * -1 }).call(data)
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
    @api_base_uri || 'https://api.pigci.com/v1'
  end

  attr_accessor :api_verify_ssl
  def api_verify_ssl
    !@api_verify_ssl.nil? ? @api_verify_ssl : true
  end

  attr_accessor :api_key

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
    self.load_i18ns!

    # Make sure our directories exist
    Dir.mkdir(tmp_directory) unless File.exist?(tmp_directory)
    Dir.mkdir(output_directory) unless File.exist?(output_directory)

    # Purge any previous logs and attach some listeners
    self.profiler_engine.setup!
  end

  def load_i18ns!
    I18n.available_locales << PigCI.locale
    I18n.load_path += Dir["#{File.expand_path('../../config/locales/pig_ci', __FILE__)}/*.{rb,yml}"]
  end

  def run_exit_tasks!
    return if PigCI.pid != Process.pid || !PigCI.profiler_engine.request_captured?

    puts '[PigCI] Finished, expect an output or something in a moment'

    puts "[PigCI] Saving your reports…"
    self.profiler_engine.profilers.each(&:save!)

    puts "[PigCI] Printing your reports…\n\n"
    PigCI::Summary::Terminal.new(reports: self.profiler_engine.reports).print!

    puts "[PigCI] Saving to project root…\n\n"
    PigCI::Summary::HTML.new(reports: self.profiler_engine.reports).save!

    if PigCI.api_key.present?
      puts "[PigCI] Sharing your reports…"
      PigCI::Api::ShareReports.new(reports: self.profiler_engine.reports).share
    else
      puts "[PigCI] You can share your reports PigCI with your colleagues via https://pigci.com/"
    end
  end
end

at_exit do
  PigCI.run_exit_tasks!
end
