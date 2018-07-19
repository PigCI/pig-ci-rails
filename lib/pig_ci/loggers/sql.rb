class PigCi::Loggers::Sql
  def self.purge_previous_snapshot!
    File.open(PigCi.tmp_directory.join('pig-ci-sql.txt'), 'w') {|file| file.truncate(0) }
  end
end
