require "spec_helper"

describe PigCI do
  describe "::api_key=" do
    subject { PigCI.api_key = "sample-api" }

    it {
      expect { subject }.to output(/DEPRECATED: PigCI.com API has been retired/).to_stdout
    }
  end

  describe "::start" do
    before { PigCI.pid = nil }
    after { PigCI.pid = nil }

    subject { PigCI.start }

    it do
      expect(PigCI).to receive(:load_i18ns!).once
      expect(PigCI.profiler_engine).to receive(:setup!).once
      expect { subject }.to change(PigCI, :pid).from(nil).to(Integer)
    end

    context "with block passes" do
      subject do
        PigCI.start do |config|
          config.max_change_percentage_precision = 2
        end
      end

      it do
        expect(PigCI).to receive(:load_i18ns!).once
        expect(PigCI.profiler_engine).to receive(:setup!).once
        expect { subject }.to change(PigCI, :max_change_percentage_precision).from(1).to(2)
      end
    end
  end

  describe "::enabled?" do
    subject { PigCI.enabled? }
    it { is_expected.to eq(true) }
  end

  describe "::enabled=" do
    after { PigCI.enabled = true }
    subject { PigCI.enabled = false }

    it { expect { subject }.to change { PigCI.enabled? }.from(true).to(false) }
  end

  describe "::ignore_cached_queries?" do
    subject { PigCI.ignore_cached_queries? }
    it { is_expected.to eq(false) }
  end

  describe "::ignore_cached_queries=" do
    after { PigCI.ignore_cached_queries = false }
    subject { PigCI.ignore_cached_queries = true }

    it { expect { subject }.to change { PigCI.ignore_cached_queries? }.from(false).to(true) }
  end

  describe "::thresholds.memory" do
    subject { PigCI.thresholds.memory }
    it { is_expected.to eq(350) }
  end

  describe "::thresholds=" do
    after do
      PigCI.thresholds = {}
    end

    context "overwriting the memory" do
      subject { PigCI.thresholds = {memory: 300} }
      it { expect { subject }.to change { PigCI.thresholds.memory }.from(350).to(300) }
    end

    context "resetting the thresholds" do
      subject { PigCI.thresholds = {} }
      it do
        PigCI.thresholds.memory = 300
        expect { subject }.to change { PigCI.thresholds.memory }.from(300).to(350)
      end
    end
  end

  describe "::load_i18n!" do
    pending
  end

  describe "::run_exit_tasks!" do
    after { PigCI.pid = nil }
    subject { PigCI.run_exit_tasks! }

    context "without PigCI being started" do
      it do
        expect { subject }.to_not output(/\[PigCI\]/).to_stdout
      end
    end

    context "PigCI started (pid is present), but not requests made" do
      before { PigCI.pid = Process.pid }

      it do
        expect(PigCI::Summary::Terminal).to_not receive(:new)
        expect(PigCI::Summary::HTML).to_not receive(:new)
        subject
      end
    end

    context "PigCI started, with request data logged" do
      let(:profiler_sample_log_data) { File.open(File.join("spec", "fixtures", "files", "profiler.txt")).read }
      let(:summary_terminal) { double :summary_terminal, print!: true }
      let(:summary_html) { double :summary_terminal, save!: true }
      let(:summary_ci) { double :summary_ci, call!: true }

      before do
        PigCI.pid = Process.pid
        PigCI.profiler_engine.request_captured!

        # Also write some test data to sample files
        PigCI.profiler_engine.profilers.each do |profiler|
          File.open(profiler.log_file, "w") { |file| file.write(profiler_sample_log_data) }
        end
      end
      after { PigCI.profiler_engine.request_captured = nil }

      it do
        expect(PigCI::Summary::Terminal).to receive(:new).and_return(summary_terminal)
        expect(PigCI::Summary::HTML).to receive(:new).and_return(summary_html)
        expect(PigCI::Summary::CI).to receive(:new).and_return(summary_ci)
        subject
      end

      context "generate_terminal_summary set to false" do
        before { PigCI.generate_terminal_summary = false }
        after { PigCI.generate_terminal_summary = true }

        it do
          expect(PigCI::Summary::Terminal).to_not receive(:new)
          expect(PigCI::Summary::HTML).to receive(:new).and_return(summary_html)
          expect(PigCI::Summary::CI).to receive(:new).and_return(summary_ci)
          subject
        end
      end

      context "generate_html_summary set to false" do
        before { PigCI.generate_html_summary = false }
        after { PigCI.generate_html_summary = true }

        it do
          expect(PigCI::Summary::Terminal).to receive(:new).and_return(summary_terminal)
          expect(PigCI::Summary::HTML).to_not receive(:new)
          expect(PigCI::Summary::CI).to receive(:new).and_return(summary_ci)
          subject
        end
      end
    end
  end
end
