require 'colorized_string'

class PigCI::Summary::CI < PigCI::Summary
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

    Kernel.exit 2 if over_limit
  end

  private

  def print_report(report)

    max_and_limit = [
      report.max_for(@timestamp).to_s,
      '/',
      report.limit
    ].join(' ')

    if report.over_limit_for?(@timestamp)
      puts "#{report.i18n_name}: #{ColorizedString[max_and_limit].colorize(:red)}\n"
    else
      puts "#{report.i18n_name}: #{ColorizedString[max_and_limit].colorize(:green)}\n"
    end
  end
end
