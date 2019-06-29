class PigCI::Summary
  def initialize(reports:)
    @reports = reports
  end
end

require 'pig_ci/summary/html'
require 'pig_ci/summary/terminal'
