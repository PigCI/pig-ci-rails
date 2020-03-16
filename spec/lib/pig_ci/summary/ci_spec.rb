require 'spec_helper'

describe PigCI::Summary::CI do
  let(:reports) do
    [
      PigCI::Report.new(i18n_key: 'profiler', historical_log_file: File.join('spec', 'fixtures', 'files', 'profiler.json'))
    ]
  end

  describe '#call!' do
    let(:profiler_sample_log_data) { File.open(File.join('spec', 'fixtures', 'files', 'profiler.txt')).read }
    subject { described_class.new(reports: reports).call! }

    it 'Outputs the data to terminal screen' do
      expect { subject }.to output(/translation missing: en.pig_ci.report.profiler.name/).to_stdout
    end
  end
end
