class PigCI::Metric::Current
  def initialize(log_file:)
    @log_file = log_file
  end

  def to_h
    @to_h = {}

    File.foreach(@log_file) do |f|
      key, value = f.strip.split("|")
      value = value.to_i

      @to_h[key] ||= {
        key: key,
        max: value,
        min: value,
        mean: 0,
        total: 0,
        number_of_requests: 0
      }
      @to_h[key][:max] = value if value > @to_h[key][:max]
      @to_h[key][:min] = value if value < @to_h[key][:min]
      @to_h[key][:total] += value
      @to_h[key][:number_of_requests] += 1
      @to_h[key][:mean] = @to_h[key][:total] / @to_h[key][:number_of_requests]
    end

    @to_h.collect { |_k, d| d }
  end
end
