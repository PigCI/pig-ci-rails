class PigCI::Report::Memory < PigCI::Report
  def self.format_data(data)
    data[:max] = (data[:max] / bytes_in_a_megabyte).round(2)
    data[:min] = (data[:min] / bytes_in_a_megabyte).round(2)
    data[:mean] = (data[:mean] / bytes_in_a_megabyte).round(2)

    data
  end

  def self.bytes_in_a_megabyte
    @bytes_in_a_megabyte ||= BigDecimal(1048576)
  end
end
