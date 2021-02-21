class PigCI::Metric::Historical
  def initialize(historical_log_file:)
    @historical_log_file = historical_log_file
  end

  def to_h
    @to_h ||= read_historical_log_file.sort_by { |timestamp, _data| timestamp.to_s.to_i * -1 }.to_h
  end

  # In future this might honour some limit.
  def append!(timestamp:, metric:, data:)
    to_h
    @to_h[timestamp] ||= {}
    @to_h[timestamp][metric] = data
    remove_old_historical_data!
    save!
  end

  def add_change_percentage_and_append!(timestamp:, metric:, data:)
    max_change_percentage_data = {}
    max_change_percentage_data[timestamp] = {}
    max_change_percentage_data[timestamp][metric] = data

    data = PigCI::Metric::Historical::ChangePercentage.new(previous_data: to_h, data: max_change_percentage_data).updated_data
    append!(timestamp: timestamp, metric: metric, data: data[timestamp][metric])
  end

  private

  def remove_old_historical_data!
    new_historical_data = @to_h
      .sort_by { |timestamp, _data| timestamp.to_s.to_i * -1 }[0..(PigCI.historical_data_run_limit - 1)]
      .to_h
      .sort_by { |timestamp, _data| timestamp.to_s.to_i * -1 }.to_h
    @to_h = new_historical_data
  end

  def read_historical_log_file
    if File.exist?(@historical_log_file)
      JSON.parse(File.open(@historical_log_file, "r").read, symbolize_names: true)
    else
      {}
    end
  end

  def save!
    File.write(@historical_log_file, @to_h.to_json)
    @to_h = nil
  end
end

require "pig_ci/metric/historial/change_percentage"
