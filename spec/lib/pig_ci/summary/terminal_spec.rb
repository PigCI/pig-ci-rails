require 'spec_helper'

describe PigCI::Summary::Terminal do
  let(:profilers) do
    [
      PigCI::Profiler.new
    ]
  end
  let(:reports) do
    [
      PigCI::Report.new
    ]
  end

  describe '#print!' do
    let(:profiler_sample_log_data) { File.open(File.join('spec', 'fixtures', 'files', 'profiler.txt')).read }
    subject { PigCI::Summary::Terminal.new(reports: reports).print! }

    before do
      profilers.each do |profiler|
        # TODO: This isn't writing quite right I think.
        File.open(profiler.log_file, 'w') { |file| file.write(profiler_sample_log_data) }
        profiler.save!
      end
    end

    it 'Outputs some data' do
      pending
      expect { subject }.to output("[PigCI] Peak memory per a request:\n").to_stdout
    end
  end
end
