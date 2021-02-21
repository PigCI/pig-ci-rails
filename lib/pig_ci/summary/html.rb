# This will make human friendly HTML report for developers to compare runs locally.
# It aims to save to the project root in /pig-ci.
# It is inspired by https://github.com/colszowka/simplecov-html

require "erb"

class PigCI::Summary::HTML < PigCI::Summary
  def initialize(reports:)
    @reports = reports
  end

  def save!
    copy_assets!
    File.write(index_file_path, template("index").result(binding))

    puts I18n.t("pig_ci.summary.saved_successfully", output_directory: PigCI.output_directory)
  end

  private

  def render_report(report)
    template("report").result(binding)
  end

  def timestamps
    @reports.first.timestamps
  end

  def template(name)
    ERB.new(File.read(File.join(File.dirname(__FILE__), "../views", "#{name}.erb")))
  end

  def index_file_path
    PigCI.output_directory.join("index.html")
  end

  def copy_assets!
    Dir.mkdir(output_assets_directory) unless File.exist?(output_assets_directory)
    FileUtils.copy_entry(assets_directory, output_assets_directory)
  end

  def output_assets_directory
    PigCI.output_directory.join("assets")
  end

  def assets_directory
    File.join(File.dirname(__FILE__), "../../../public/assets")
  end
end
