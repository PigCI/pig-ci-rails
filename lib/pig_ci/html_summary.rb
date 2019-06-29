# This will make human friendly HTML report for developers to compare runs locally.
# It aims to save to the project root in /pig-ci.
# It is inspired by https://github.com/colszowka/simplecov-html 

require 'erb'

class PigCi::HTMLSummary
  def initialize(reports:)
    @reports = reports
  end

  def save!
    File.write(index_file_path, template('index').result(binding))

    # Turns out these are already saved? - I guess this is just adding the HTML to view them.
  end

  private

  def template(name)
    ERB.new(File.read(File.join(File.dirname(__FILE__), 'views', "#{name}.erb")))
  end

  def index_file_path
    PigCi.output_directory.join('index.html')
  end

  def report_filenames_as_json
    @reports.collect(&:output_file).to_json
  end
end
