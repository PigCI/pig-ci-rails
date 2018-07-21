require 'get_process_mem'
require 'terminal-table'

class PigCi::Loggers::Memory
  def self.setup!
    File.open(PigCi.tmp_directory.join('pig-ci-memory.txt'), 'w') {|file| file.truncate(0) }
  end

  def self.touch_memory!
    @memory = ::GetProcessMem.new.kb
  end

  def self.append_row(key)
    File.open(PigCi.tmp_directory.join('pig-ci-memory.txt'),"a+") do |f|
      f.puts([key, (::GetProcessMem.new.kb - @memory)].join('|'))
    end
  end

  def self.report!

    table = Terminal::Table.new headings: ['Key', 'Max', 'Min', 'Mean', 'Number of requests'] do |t|
      aggregated_memory_totals.each do |data|
        t << [
          data[:key],
          data[:max],
          data[:min],
          (data[:total] / data[:number_of_requests]),
          data[:number_of_requests]
        ]
      end
    end

    puts "[PigCI] Aggregated Memory Totals:\n"
    puts table
  end

  def self.aggregated_memory_totals
    aggregated_totals = {}

    File.foreach(PigCi.tmp_directory.join('pig-ci-memory.txt')) do |f|
      key, memory = f.strip.split('|')
      memory = memory.to_i

      aggregated_totals[key] ||= {
        key: key,
        max: memory,
        min: memory,
        total: 0,
        number_of_requests: 0
      }
      aggregated_totals[key][:max] = memory if aggregated_totals[key][:max] < memory
      aggregated_totals[key][:min] = memory if aggregated_totals[key][:max] > memory
      aggregated_totals[key][:total] += memory

      aggregated_totals[key][:number_of_requests] += 1
    end

    aggregated_totals.collect{ |k,d| d }.sort_by { |k| k[:max] * -1 }
  end
end
