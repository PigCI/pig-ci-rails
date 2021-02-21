class PigCI::Metric::Historical::ChangePercentage
  def initialize(previous_data:, data:)
    @previous_data = previous_data
    @data = data
    @timestamp = @data.keys.first
    @profiler = @data[@timestamp].keys.first
  end

  def updated_data
    @data[@timestamp][@profiler].collect do |data|
      previous_run_data = previous_run_data_for_key(data[:key]) || data

      data[:max_change_percentage] = (((BigDecimal(data[:max]) - BigDecimal(previous_run_data[:max])) / BigDecimal(previous_run_data[:max])) * 100).round(PigCI.max_change_percentage_precision)
      data[:max_change_percentage] = BigDecimal("0") if data[:max_change_percentage].to_s == "NaN" || data[:max_change_percentage] == BigDecimal("-0.0")
      data[:max_change_percentage] = data[:max_change_percentage].to_f

      data
    end

    @data
  end

  private

  def previous_run_data_for_key(key)
    previous_data_keys.each do |previous_run_key|
      @previous_data[previous_run_key][@profiler.to_sym].each do |raw_previous_run_data|
        return raw_previous_run_data if raw_previous_run_data[:key] == key
      end
    end
    nil
  end

  def previous_data_keys
    @previous_data_keys ||= @previous_data.keys.sort.reverse
  end
end
