class PigCi::Formatter
  def initialize(reports:)
    @reports = reports
  end

  def save!
    raise @reports.collect(&:to_json).inspect
  end
end
