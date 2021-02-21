require "colorized_string"

class PigCI::Summary::CI < PigCI::Summary
  def initialize(reports:)
    @reports = reports
    @timestamp = PigCI.run_timestamp
  end

  def call!
    puts ""
    puts I18n.t("pig_ci.summary.ci_start")

    over_threshold = false
    @reports.each do |report|
      print_report(report)
      over_threshold = true if report.over_threshold_for?(@timestamp)
    end

    fail_with_error! if over_threshold
    puts ""
  end

  private

  def fail_with_error!
    puts I18n.t("pig_ci.summary.ci_failure")
    Kernel.exit(2)
  end

  def print_report(report)
    max_and_threshold = [
      report.max_for(@timestamp).to_s,
      "/",
      report.threshold
    ].join(" ")

    if report.over_threshold_for?(@timestamp)
      puts "#{report.i18n_name}: #{ColorizedString[max_and_threshold].colorize(:red)}\n"
    else
      puts "#{report.i18n_name}: #{ColorizedString[max_and_threshold].colorize(:green)}\n"
    end
  end
end
