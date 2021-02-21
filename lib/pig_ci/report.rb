class PigCI::Report
  attr_accessor :historical_log_file, :i18n_key

  def initialize(historical_log_file: nil, i18n_key: nil, timestamp: nil)
    @i18n_key = i18n_key || self.class.name.underscore.split("/").last
    @historical_log_file = historical_log_file || PigCI.tmp_directory.join("#{@i18n_key}.json")
    @timestamp = timestamp || PigCI.run_timestamp
  end

  def headings
    column_keys.collect { |key| I18n.t(".attributes.#{key}", scope: i18n_scope, locale: PigCI.locale) }
  end

  def i18n_name
    I18n.t(".name", scope: i18n_scope, locale: PigCI.locale)
  end

  def max_for(timestamp)
    sorted_and_formatted_data_for(timestamp).collect { |row| row[:max] }.max
  end

  def threshold
    PigCI.thresholds.dig(@i18n_key.to_sym)
  end

  def over_threshold_for?(timestamp)
    return false unless threshold.present? && max_for(timestamp).present?

    max_for(timestamp) > threshold
  end

  def sorted_and_formatted_data_for(timestamp)
    data_for(timestamp)[@i18n_key.to_sym].sort_by { |data|
      PigCI.report_row_sort_by(data)
    }.collect do |data|
      self.class.format_row(data)
    end
  end

  def to_payload_for(timestamp)
    {
      profiler: @i18n_key.to_sym,
      data: data_for(timestamp)[@i18n_key.to_sym]
    }
  end

  def historical_data
    @historical_data ||= PigCI::Metric::Historical.new(historical_log_file: @historical_log_file).to_h
  end

  def timestamps
    historical_data.keys
  end

  def column_keys
    %i[key max min mean number_of_requests max_change_percentage]
  end

  def i18n_scope
    @i18n_scope ||= "pig_ci.report.#{i18n_key}"
  end

  def self.format_row(row)
    row = row.dup
    row[:max_change_percentage] = "#{row[:max_change_percentage]}%"
    row
  end

  private

  def data_for(timestamp)
    historical_data[timestamp.to_sym]
  end
end

require "pig_ci/report/memory"
require "pig_ci/report/request_time"
require "pig_ci/report/database_request"
