class PigCI::Metric::Historical::ChangePercentage
  def initialize(previous_data: previous_data, data: data)
    @previous_data = previous_data
    @data = data
  end

  def updated_data
    @data
  end
end
