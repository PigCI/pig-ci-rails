class PigCi::Loggers
  def self.setup!
    File.open(log_file, 'w') {|file| file.truncate(0) }
  end

  private
  def self.log_file
    PigCi.tmp_directory.join(
      "pig-ci-#{name.split('::').last.gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase}.txt"
    )
  end

  def self.log_value;end

  def self.append_row(key)
    File.open(log_file, 'a+') do |f|
      f.puts([key, log_value].join('|'))
    end
  end
end
