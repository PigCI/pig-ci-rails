require 'spec_helper'

describe PigCI::HTMLSummary do
  let(:reports) do
    [
      PigCI::Report::Memory,
      PigCI::Report::InstantiationActiveRecord,
      PigCI::Report::RequestTime,
      PigCI::Report::SqlActiveRecord
    ]
  end

  describe '#save!' do
    subject { PigCI::HTMLSummary.new(reports: reports).save! }

    let(:index_file) { PigCI.output_directory.join('index.html') }

    before do
      File.open(index_file, 'w') {|file| file.truncate(0) }
    end

    it 'writes an html index file containing the the json' do
      expect { subject }.to change(index_file, :read).from('').to(/<html(.*)data-pig-ci-results/sm)
        .and output("[PigCI] PigCI report generated to #{PigCI.output_directory}\n").to_stdout
    end
  end
end
