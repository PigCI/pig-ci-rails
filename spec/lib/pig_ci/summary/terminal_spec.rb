require 'spec_helper'

describe PigCI::Summary::Terminal do
  let(:profilers) do
    [
      PigCI::Profiler.new(i18n_key: 'memory')
    ]
  end
  let(:reports) do
    [
      PigCI::Report.new(i18n_key: 'memory')
    ]
  end

  describe '#print!' do
    let(:profiler_sample_log_data) { File.open(File.join('spec', 'fixtures', 'files', 'profiler.txt')).read }
    subject { PigCI::Summary::Terminal.new(reports: reports).print! }

    before do
      profilers.each do |profiler|
        File.open(profiler.log_file, 'w') { |file| file.write(profiler_sample_log_data) }
        profiler.save!
      end
    end

    it 'Outputs the data to terminal screen' do
      expect { subject }.to output(/Peak memory per a request/).to_stdout
    end
  end
end
