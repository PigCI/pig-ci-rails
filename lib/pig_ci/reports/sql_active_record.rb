require 'terminal-table'

class PigCi::Reports::SqlActiveRecord < PigCi::Reports
  def self.aggregated_data
    aggregated_totals = {}

    File.foreach(log_file) do |f|
      key, memory = f.strip.split('|')
      memory = memory.to_i

      aggregated_totals[key] ||= {
        key: key,
        max: memory,
        min: memory,
        mean: 0,
        total: 0,
        number_of_requests: 0
      }
      aggregated_totals[key][:max] = memory if memory > aggregated_totals[key][:max]
      aggregated_totals[key][:min] = memory if memory < aggregated_totals[key][:min]
      aggregated_totals[key][:total] += memory
      aggregated_totals[key][:number_of_requests] += 1
      aggregated_totals[key][:mean] = aggregated_totals[key][:total] / aggregated_totals[key][:number_of_requests]
    end

    aggregated_totals.collect{ |k,d| d }.sort_by { |k| k[:max] * -1 }
  end

  private
  def self.column_keys
    [:key, :max, :min, :mean, :number_of_requests]
  end
end
