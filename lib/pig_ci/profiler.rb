class PigCI::Profiler
  attr_accessor :log_value, :log_file, :historical_log_file, :i18n_key

  def initialize(i18n_key: nil, log_file: nil, historical_log_file: nil)
    @i18n_key = i18n_key || self.class.name.underscore.split("/").last
    @log_file = log_file || PigCI.tmp_directory.join("#{@i18n_key}.txt")
    @historical_log_file = historical_log_file || PigCI.tmp_directory.join("#{@i18n_key}.json")
    @log_value = 0
  end

  def setup!
    File.open(log_file, "w") { |file| file.truncate(0) }
  end

  def reset!
    @log_value = 0
  end

  def log_request!(request_key)
    File.open(log_file, "a+") do |f|
      f.puts([request_key, log_value].join("|"))
    end
  end

  def save!
    historical_data = PigCI::Metric::Historical.new(historical_log_file: @historical_log_file)
    historical_data.add_change_percentage_and_append!(
      timestamp: PigCI.run_timestamp,
      metric: i18n_key,
      data: PigCI::Metric::Current.new(log_file: log_file).to_h
    )
  end

  def increment!(*)
    raise NotImplementedError
  end
end

require "pig_ci/profiler/memory"
require "pig_ci/profiler/request_time"
require "pig_ci/profiler/database_request"
