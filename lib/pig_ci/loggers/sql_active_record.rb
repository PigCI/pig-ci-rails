class PigCi::Loggers::SqlActiveRecord
  def self.setup!
    File.open(PigCi.tmp_directory.join('pig-ci-sql_active_record.txt'), 'w') {|file| file.truncate(0) }
  end

  def self.start!
    @query_count = 0
  end


  def self.increment!(by: 1)
    @query_count += by
  end

  def self.append_row(key)
    File.open(PigCi.tmp_directory.join('pig-ci-sql_active_record.txt'),"a+") do |f|
      f.puts([key, @query_count].join('|'))
    end
  end
end
