require 'spec_helper'

describe PigCi::HTMLSummary do
  let(:reports) do
    [
      PigCi::Report::Memory,
      PigCi::Report::InstantiationActiveRecord,
      PigCi::Report::RequestTime,
      PigCi::Report::SqlActiveRecord
    ]
  end

  describe '#save!' do
    subject { PigCi::HTMLSummary.new(reports: reports).save! }

    let(:index_file) { PigCi.output_directory.join('index.html') }

    before do
      File.open(index_file, 'w') {|file| file.truncate(0) }
    end

    it 'writes an html index file containing the the json' do
      expect { subject }.to change(index_file, :read).from('').to(/<html>(.*)data-pig-ci-results/sm)
    end
  end
end
