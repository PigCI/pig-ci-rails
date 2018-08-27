require 'terminal-table'

class PigCi::Reports
  def self.print!
    puts "[PigCI] #{report_name}:\n"
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
    PigCi.tmp_directory.join(
      "pig-ci-#{name.split('::').last.gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase}.txt"
    )
  end

  def self.report_name
    name.split('::').last.gsub(/([a-z\d])([A-Z])/,'\1 \2')
  end
end
