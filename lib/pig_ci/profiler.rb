class PigCI::Profiler
  attr_accessor :log_value

  def setup!
    File.open(log_file, 'w') {|file| file.truncate(0) }
  end

  def reset!
    @log_value = nil
  end

  def save!(request_key)
    File.open(log_file, 'a+') do |f|
      f.puts([request_key, log_value].join('|'))
    end
  end

  def log_file
    @log_file ||= PigCI.tmp_directory.join("#{i18n_key}.txt")
  end

  def i18n_key
    @i18n_key ||= self.class.name.underscore.split('/').last
  end
end

require 'pig_ci/profiler/instantiation_active_record'
require 'pig_ci/profiler/memory'
require 'pig_ci/profiler/request_time'
require 'pig_ci/profiler/sql_active_record'
