require 'colorized_string'

class PigCI::Summary::CI < PigCI::Summary
  def initialize(reports:)
    @reports = reports
    @timestamp = PigCI.run_timestamp
  end

  def call!
    puts ''
    puts I18n.t('pig_ci.summary.ci_start')

    over_limit = false
    @reports.each do |report|
      print_report(report)
      over_limit = true if report.over_limit_for?(@timestamp)
    end

    fail_with_error! if over_limit
    puts ''
  end

  private

  def fail_with_error!
    puts I18n.t('pig_ci.summary.ci_failure')
    Kernel.exit(2)
  end

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
