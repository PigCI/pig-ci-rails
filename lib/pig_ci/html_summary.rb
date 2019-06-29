# This will make human friendly HTML report for developers to compare runs locally.
# It aims to save to the project root in /pig-ci.
# It is inspired by https://github.com/colszowka/simplecov-html 
class PigCi::HTMLSummary
  def initialize(reports:)
    @reports = reports
  end

  def save!
    File.write(index_file, '<html> <div data-pig-ci-results>')

    # Turns out these are already saved? - I guess this is just adding the HTML to view them.
  end

  private

  def index_file
    PigCi.output_directory.join('index.html')
  end

  def report_filenames_as_json
    @reports.collect(&:output_file).to_json
  end
end
