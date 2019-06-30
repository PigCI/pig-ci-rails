class PigCI::Report::Memory < PigCI::Report
  def self.format_row(row)
    row = super
    row[:max] = (row[:max] / bytes_in_a_megabyte).round(2)
    row[:min] = (row[:min] / bytes_in_a_megabyte).round(2)
    row[:mean] = (row[:mean] / bytes_in_a_megabyte).round(2)
    row[:total] = (row[:total] / bytes_in_a_megabyte).round(2)

    row
  end

  def self.bytes_in_a_megabyte
    @bytes_in_a_megabyte ||= BigDecimal(1048576)
  end
end
