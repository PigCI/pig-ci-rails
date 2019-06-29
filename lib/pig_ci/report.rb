class PigCI::Report
  attr_accessor :historical_log_file, :i18n_key

  def initialize(historical_log_file: nil)
    @i18n_key = self.class.name.underscore.split('/').last
    @historical_log_file = historical_log_file || PigCI.tmp_directory.join("#{@i18n_key}.json")
  end

  def headings
    column_keys.collect { |key| I18n.t(".attributes.#{key}", scope: i18n_scope) }
  end

  def i18n_name
    I18n.t('.name', scope: i18n_scope)
  end

  def sorted_and_formatted_data_for(timestamp)
    historical_data[timestamp.to_sym][@i18n_key.to_sym].sort_by do 
      |d| PigCI.report_print_sort_by(d) 
    end[0..PigCI.report_print_limit].collect do |data|
      format_row(data)
    end
  end

  def historical_data
    # TODO: Sort this later
    @historical_data ||= PigCI::Metric::Historical.new(historical_log_file: @historical_log_file).to_h
  end

  def latest_report
    @latest_report ||= PigCI::Metric::Historical.new(historical_log_file: @historical_log_file)
                                                .find_by_timestamp_and_profiler(PigCI.run_timestamp, @i18n_key)
  end

  def column_keys
    [:key, :max, :min, :mean, :number_of_requests, :max_change_percentage]
  end

  def i18n_scope
    @i18n_scope ||= "pig_ci.report.#{i18n_key}"
  end

  private

  def format_row(row)
    row
  end
end

require 'pig_ci/report/instantiation_active_record'
require 'pig_ci/report/memory'
require 'pig_ci/report/request_time'
require 'pig_ci/report/sql_active_record'
