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

    it 'Outputs the data to terminal screen without stopping CI' do
      expect(Kernel).to_not receive(:exit)
      expect { subject }.to output(/translation missing: en.pig_ci.report.profiler.name/).to_stdout
    end

    context 'report is over the limit' do
      before do
        allow(reports[0]).to receive(:over_limit_for?).and_return(true)
      end

      it 'Outputs the data to terminal screen without stopping CI' do
        expect(Kernel).to receive(:exit).with(2)
        expect { subject }.to output(/PigCI: This commit has exceeded the threshold limits defined in PigCI\.limits/).to_stdout
      end
    end
  end
end
