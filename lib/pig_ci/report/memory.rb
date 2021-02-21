class PigCI::Report::Memory < PigCI::Report
  def self.format_row(_unformatted_row)
    row = super
    row[:max] = (row[:max] / bytes_in_a_megabyte).round(PigCI.report_memory_precision)
    row[:min] = (row[:min] / bytes_in_a_megabyte).round(PigCI.report_memory_precision)
    row[:mean] = (row[:mean] / bytes_in_a_megabyte).round(PigCI.report_memory_precision)
    row[:total] = (row[:total] / bytes_in_a_megabyte).round(PigCI.report_memory_precision)

    row
  end

  def self.bytes_in_a_megabyte
    @bytes_in_a_megabyte ||= BigDecimal("1_048_576")
  end
end
