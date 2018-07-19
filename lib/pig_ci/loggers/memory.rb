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
end
