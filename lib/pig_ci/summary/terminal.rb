require 'terminal-table'
require 'colorized_string'

class PigCI::Summary::Terminal < PigCI::Summary
  def initialize(reports:)
    @reports = reports
    @timestamp = PigCI.run_timestamp
  end

  def print!
    @reports.each do |report|
      print_report(report)
    end

  end

  private

  def print_report(report)
    puts "[PigCI] #{report.i18n_name}:\n"

    table = ::Terminal::Table.new headings: report.headings do |t|
      report.sorted_and_formatted_data_for(@timestamp).each do |data|
        t << report.column_keys.collect { |key| data[key] }
      end
    end
    puts table
    puts "\n"
  end
end
