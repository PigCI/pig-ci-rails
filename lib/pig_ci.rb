require "active_support"
require "active_support/core_ext/string/inflections"
require "rake"

require "pig_ci/version"
require "pig_ci/configuration"
require "pig_ci/decorator"
require "pig_ci/summary"
require "pig_ci/profiler_engine"
require "pig_ci/profiler"
require "pig_ci/metric"
require "pig_ci/report"
require "pig_ci/test_frameworks"

module PigCI
  extend self

  attr_accessor :pid

  attr_writer :enabled
  def enabled?
    @enabled.nil? ? true : @enabled
  end

  # Rails caches repeated queries within the same request. You can not count
  # any cached queries if you'd like.
  attr_writer :ignore_cached_queries
  def ignore_cached_queries?
    @ignore_cached_queries.nil? ? false : @ignore_cached_queries
  end

  attr_writer :tmp_directory
  def tmp_directory
    @tmp_directory || Pathname.new(Dir.getwd).join("tmp", "pig-ci")
  end

  attr_writer :output_directory
  def output_directory
    @output_directory || Pathname.new(Dir.getwd).join("pig-ci")
  end

  attr_accessor :generate_terminal_summary
  def generate_terminal_summary?
    @generate_terminal_summary.nil? || @generate_terminal_summary
  end

  attr_accessor :generate_html_summary
  def generate_html_summary?
    @generate_html_summary.nil? || @generate_html_summary
  end

  attr_writer :max_change_percentage_precision
  def max_change_percentage_precision
    @max_change_percentage_precision || 1
  end

  attr_writer :report_memory_precision
  def report_memory_precision
    @report_memory_precision || 2
  end

  attr_writer :during_setup_eager_load_application
  def during_setup_eager_load_application?
    @during_setup_eager_load_application.nil? || @during_setup_eager_load_application
  end

  attr_writer :during_setup_make_blank_application_request
  def during_setup_make_blank_application_request?
    @during_setup_make_blank_application_request.nil? || @during_setup_make_blank_application_request
  end

  attr_writer :during_setup_precompile_assets
  def during_setup_precompile_assets?
    @during_setup_precompile_assets.nil? || @during_setup_precompile_assets
  end

  attr_writer :terminal_report_row_limit
  def terminal_report_row_limit
    @terminal_report_row_limit || -1
  end

  # PigCI.report_row_sort_by = Proc.new { |d| d[:max_change_percentage] * -1 }
  attr_writer :report_row_sort_by
  def report_row_sort_by(data)
    (@report_row_sort_by || proc { |d| d[:max].to_i * -1 }).call(data)
  end

  attr_writer :historical_data_run_limit
  def historical_data_run_limit
    @historical_data_run_limit ||= 10
  end

  attr_writer :run_timestamp
  def run_timestamp
    @run_timestamp ||= Time.now.to_i.to_s
  end

  attr_writer :profiler_engine
  def profiler_engine
    @profiler_engine ||= PigCI::ProfilerEngine::Rails.new
  end

  attr_writer :commit_sha1
  def commit_sha1
    @commit_sha1 || ENV["CI_COMMIT_ID"] || ENV["CIRCLE_SHA1"] || ENV["TRAVIS_COMMIT"] || `git rev-parse HEAD`.strip
  end

  attr_writer :head_branch
  def head_branch
    @head_branch || ENV["CI_BRANCH"] || ENV["CIRCLE_BRANCH"] || ENV["TRAVIS_BRANCH"] || `git rev-parse --abbrev-ref HEAD`.strip
  end

  # Throw deprecation notice for setting API
  def api_key=(value)
    puts "DEPRECATED: PigCI.com API has been retired, you no longer need to set config.api_key in your spec/rails_helper.rb file."
  end

  attr_writer :locale
  def locale
    @locale || :en
  end

  def thresholds=(values)
    @thresholds = PigCI::Configuration::Thresholds.new(values)
  end

  def thresholds
    @thresholds ||= PigCI::Configuration::Thresholds.new
  end

  module_function

  def start(&block)
    self.pid = Process.pid
    PigCI::TestFrameworks::Rspec.configure! if defined?(::RSpec)

    block&.call(self)

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
    I18n.load_path += Dir["#{File.expand_path("../config/locales/pig_ci", __dir__)}/*.{rb,yml}"]
  end

  def run_exit_tasks!
    return if PigCI.pid != Process.pid || !PigCI.profiler_engine.request_captured?

    # Save all the reports as JSON
    profiler_engine.profilers.each(&:save!)

    # Print the report summary to Terminal
    PigCI::Summary::Terminal.new(reports: profiler_engine.reports).print! if PigCI.generate_terminal_summary?

    # Save the report summary to the project root.
    PigCI::Summary::HTML.new(reports: profiler_engine.reports).save! if PigCI.generate_html_summary?

    # Make sure CI fails when metrics are over thresholds.
    PigCI::Summary::CI.new(reports: profiler_engine.reports).call!
  end
end

at_exit do
  PigCI.run_exit_tasks!
end
