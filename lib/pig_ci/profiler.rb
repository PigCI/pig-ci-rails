class PigCi::Profiler
  def self.setup!
    File.open(log_file, 'w') {|file| file.truncate(0) }
  end

  private
  def self.log_file
    @log_file ||= PigCi.tmp_directory.join("#{i18n_key}.txt")
  end

  def self.i18n_key
    @i18n_key ||= name.underscore.split('/').last
  end

  def self.log_value; end

  def self.append_row(key)
    File.open(log_file, 'a+') do |f|
      f.puts([key, log_value].join('|'))
    end
  end
end

require 'pig_ci/profiler/instantiation_active_record'
require 'pig_ci/profiler/memory'
require 'pig_ci/profiler/request_time'
require 'pig_ci/profiler/sql_active_record'
