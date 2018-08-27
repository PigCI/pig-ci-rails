require 'terminal-table'

class PigCi::Reports
  def self.print!
    puts "[PigCI] #{I18n.t('.name', scope: i18n_scope)}:\n"
    table = Terminal::Table.new headings: column_keys.collect(&:to_s).collect(&:humanize) do |t|
      aggregated_data.each do |data|
        t << column_keys.collect {|key| data[key] }
      end
    end
    puts table
    puts "\n"
  end

  def self.aggregated_data
    [{
      key: 'Some Key',
      named_value: 1234
    }]
  end

  private
  def self.column_keys
    [:key, :named_value]
  end

  def self.log_file
    PigCi.tmp_directory.join("pig-ci-#{i18n_key}.txt")
  end

  def self.i18n_key
    @i18n_key ||= name.underscore.split('/').last
  end

  def self.i18n_scope
    @i18n_scope ||= "pig_ci.reports.#{i18n_key}"
  end
end
