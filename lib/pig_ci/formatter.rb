class PigCi::Formatter
  def initialize(reports:)
    @reports = reports
  end

  def save!
    File.write(output_file, report_filenames_as_json)

    # Turns out these are already saved? - I guess this is just adding the HTML to view them.
  end

  private

  def output_file
    PigCi.output_directory.join('reports.json')
  end

  def report_filenames_as_json
    @reports.collect(&:output_file).to_json
  end
end
