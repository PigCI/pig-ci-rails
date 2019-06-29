# This will make human friendly HTML report for developers to compare runs locally.
# It aims to save to the project root in /pig-ci.
# It is inspired by https://github.com/colszowka/simplecov-html 

require 'erb'

class PigCI::Summary::HTML < PigCI::Summary
  def initialize(reports:)
    @reports = reports
    @historic_reports = @reports.collect(&:output_file)
  end

  def save!
    File.write(index_file_path, template('index').result(binding))

    puts "[PigCI] PigCI report generated to #{PigCI.output_directory}"
  end

  private

  def render_report(report)
    template('report').result(binding)
  end

  def template(name)
    ERB.new(File.read(File.join(File.dirname(__FILE__), 'views', "#{name}.erb")))
  end

  def index_file_path
    PigCI.output_directory.join('index.html')
  end
end
