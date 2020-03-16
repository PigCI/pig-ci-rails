require 'terminal-table'

class PigCI::Summary::CI < PigCI::Summary
  SUCCESS = 0
  OVER_LIMTS = 2

  def initialize(reports:)
    @reports = reports
    @timestamp = PigCI.run_timestamp
  end

  def call!
    over_limit = false
    @reports.each do |report|
      print_report(report)
      over_limit = true if report.over_limit_for?(@timestamp)
    end

    Kernel.exit OVER_LIMTS if over_limit
  end

  private

  def print_report(report)
    puts "#{report.i18n_name}: #{ColorizedString[report.max_for(@timestamp).to_s].colorize(:green)}/LIMIT\n"
  end
end
