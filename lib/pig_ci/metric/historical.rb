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

  def save!
    File.write(@historical_log_file, @to_h.to_json)
  end
end
