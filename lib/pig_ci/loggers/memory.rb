require 'get_process_mem'

class PigCi::Loggers::Memory
  def self.purge_previous_snapshot!
    File.open(PigCi.tmp_directory.join('pig-ci-memory.txt'), 'w') {|file| file.truncate(0) }
  end

  def self.append_row(key)
    File.open(PigCi.tmp_directory.join('pig-ci-memory.txt'),"a+") do |f|
      f.puts([key, ::GetProcessMem.new.kb].join('|'))
    end
  end

  def self.report!
    aggregated_totals = {}

    File.foreach(PigCi.tmp_directory.join('pig-ci-memory.txt')) do |f|
      key, memory = f.strip.split('|')
      memory = memory.to_i

      aggregated_totals[key] ||= {
        max: memory,
        min: memory,
        mean: memory,
        number_of_requests: 0
      }
      aggregated_totals[key][:max] = memory if aggregated_totals[key][:max] < memory
      aggregated_totals[key][:min] = memory if aggregated_totals[key][:max] > memory
      aggregated_totals[key][:mean] = (memory + memory) / 2

      aggregated_totals[key][:number_of_requests] += 1
    end

    puts aggregated_totals.inspect
  end
end
