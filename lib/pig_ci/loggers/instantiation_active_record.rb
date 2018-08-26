class PigCi::Loggers::InstantiationActiveRecord
  def self.setup!
    File.open(PigCi.tmp_directory.join('pig-ci-instantiation_active_record.txt'), 'w') {|file| file.truncate(0) }
  end

  def self.start!
    @object_count = 0
  end

  def self.increment!(by: 1)
    @object_count += by
  end

  def self.append_row(key)
    File.open(PigCi.tmp_directory.join('pig-ci-instantiation_active_record.txt'),"a+") do |f|
      f.puts([key, @object_count].join('|'))
    end
  end
end
