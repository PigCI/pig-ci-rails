class PigCI::Metric::Historical
  def initialize(historical_log_file:)
    @historical_log_file = historical_log_file
  end

  def to_h
    @to_h ||= if File.exist?(@historical_log_file)
                JSON.parse(File.open(@historical_log_file, 'r').read, symbolize_names: true)
              else
                {}
              end
  end

  # In future this might honour some limit.
  def append!(timestamp:, metric:, data:)
    to_h
    @to_h[timestamp] ||= {}
    @to_h[timestamp][metric] = data
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

  def save!
    File.write(@historical_log_file, @to_h.to_json)
    @to_h = nil
  end
end

require 'pig_ci/metric/historial/change_percentage'
