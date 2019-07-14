# frozen_string_literal: true

require 'spec_helper'

describe PigCI do
  before { PigCI.api_key = nil }
  after { PigCI.api_key = nil }

  describe '::api_key=' do
    subject { PigCI.api_key = 'sample-api' }

    it { expect { subject }.to change(PigCI, :api_key).from(nil).to('sample-api') }
  end

  describe '::api_key?' do
    subject { PigCI.api_key = 'sample-api' }

    it { expect { subject }.to change(PigCI, :api_key?).from(false).to(true) }
  end

  describe '::start' do
    before { PigCI.pid = nil }
    after { PigCI.pid = nil }

    subject { PigCI.start }

    it do
      expect(PigCI).to receive(:load_i18ns!).once
      expect(PigCI.profiler_engine).to receive(:setup!).once
      expect { subject }.to change(PigCI, :pid).from(nil).to(Integer)
    end

    context 'with block passes' do
      subject do
        PigCI.start do |config|
          config.api_key = 'sample-api'
        end
      end

      it do
        expect(PigCI).to receive(:load_i18ns!).once
        expect(PigCI.profiler_engine).to receive(:setup!).once
        expect { subject }.to change(PigCI, :pid).from(nil).to(Integer)
                                                 .and change(PigCI, :api_key).from(nil).to('sample-api')
      end
    end
  end

  describe '::load_i18n!' do
    pending
  end

  describe '::run_exit_tasks!' do
    after { PigCI.pid = nil }
    subject { PigCI.run_exit_tasks! }

    context 'without PigCI being started' do
      it do
        expect { subject }.to_not output(/\[PigCI\]/).to_stdout
      end
    end

    context 'PigCI started (pid is present), but not requests made' do
      before { PigCI.pid = Process.pid }

      it do
        expect(PigCI::Summary::Terminal).to_not receive(:new)
        expect(PigCI::Summary::HTML).to_not receive(:new)
        expect(PigCI::Api::Reports).to_not receive(:new)
        subject
      end
    end

    context 'PigCI started, with request data logged' do
      let(:profiler_sample_log_data) { File.open(File.join('spec', 'fixtures', 'files', 'profiler.txt')).read }
      let(:summary_terminal) { double :summary_terminal, print!: true }
      let(:summary_html) { double :summary_terminal, save!: true }

      before do
        PigCI.pid = Process.pid
        PigCI.profiler_engine.request_captured!

        # Also write some test data to sample files
        PigCI.profiler_engine.profilers.each do |profiler|
          File.open(profiler.log_file, 'w') { |file| file.write(profiler_sample_log_data) }
        end
      end
      after { PigCI.profiler_engine.request_captured = nil }

      it do
        expect(PigCI::Summary::Terminal).to receive(:new).and_return(summary_terminal)
        expect(PigCI::Summary::HTML).to receive(:new).and_return(summary_html)
        expect(PigCI::Api::Reports).to_not receive(:new)
        subject
      end

      context 'generate_terminal_summary set to false' do
        before { PigCI.generate_terminal_summary = false }
        after { PigCI.generate_terminal_summary = false }

        it do
          expect(PigCI::Summary::Terminal).to_not receive(:new)
          expect(PigCI::Summary::HTML).to receive(:new).and_return(summary_html)
          expect(PigCI::Api::Reports).to_not receive(:new)
          subject
        end
      end

      context 'generate_html_summary set to false' do
        before { PigCI.generate_html_summary = false }
        after { PigCI.generate_html_summary = false }

        it do
          expect(PigCI::Summary::Terminal).to receive(:new).and_return(summary_terminal)
          expect(PigCI::Summary::HTML).to_not receive(:new)
          expect(PigCI::Api::Reports).to_not receive(:new)
          subject
        end
      end

      context 'with API key present' do
        let(:api_reports) { double :api_reports, share!: true }
        before { PigCI.api_key = 'sample-api' }

        it do
          expect(PigCI::Summary::Terminal).to receive(:new).and_return(summary_terminal)
          expect(PigCI::Summary::HTML).to receive(:new).and_return(summary_html)
          expect(PigCI::Api::Reports).to receive(:new).and_return(api_reports)
          subject
        end
      end
    end
  end
end
