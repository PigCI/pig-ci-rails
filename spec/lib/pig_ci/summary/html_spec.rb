require "spec_helper"

describe PigCI::Summary::HTML do
  let(:reports) do
    [
      PigCI::Report::Memory.new,
      PigCI::Report::RequestTime.new,
      PigCI::Report::DatabaseRequest.new
    ]
  end

  describe "#save!" do
    subject { PigCI::Summary::HTML.new(reports: reports).save! }

    let(:index_file) { PigCI.output_directory.join("index.html") }

    before do
      # Maybe also load up some files with some sample JSON.
      File.open(index_file, "w") { |file| file.truncate(0) }
    end

    it "writes an html index file containing the the json" do
      expect { subject }.to change(index_file, :read).from("").to(/<html(.*)data-pig-ci-results/sm)
        .and output("PigCI report generated to #{PigCI.output_directory}\n").to_stdout
    end
  end
end
