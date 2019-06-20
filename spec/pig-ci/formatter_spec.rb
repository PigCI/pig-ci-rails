require 'spec_helper'

describe PigCi::Formatter do
  let(:reports) do
    [
      PigCi::Report::Memory,
      PigCi::Report::InstantiationActiveRecord,
      PigCi::Report::RequestTime,
      PigCi::Report::SqlActiveRecord
    ]
  end

  describe '#save!' do
    subject { PigCi::Formatter.new(reports: reports).save! }

    let(:log_file) { PigCi.output_directory.join('reports.json') }

    before do
      File.open(log_file, 'w') {|file| file.truncate(0) }
    end

    it do
      expect(log_file.read).to eq('')
      expect { subject }.to_not raise_error
      expect(JSON.parse(log_file.read)).to be_a(Array)
    end
  end
end
