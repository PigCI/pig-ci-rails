require 'spec_helper'

describe PigCI::Profiler::RequestTime do
  let(:profiler) { PigCI::Profiler::RequestTime.new }

  describe '#reset!' do
    subject { profiler.reset! }

    it do
      profiler.start_time = nil
      expect{ subject }.to change(profiler, :start_time).from(nil).to(Time)
    end
  end

  describe '#log_request!' do
    subject { profiler.log_request!('request-key') }
    before { profiler.setup! && profiler.reset! }

    it 'sets end_time and saves the delta to the log file' do
      expect{ subject }.to change(profiler, :end_time).from(nil).to(Time)
        .and change(profiler.log_file, :read).from('').to(/request-key/)
    end
  end

  describe '#log_value' do
    subject { profiler.log_value }

    before do
      profiler.start_time = Time.at(0)
      profiler.end_time = Time.at(10)
    end
    it { is_expected.to eq(10_000) }
  end

  describe '#i18n_key' do
    subject { profiler.i18n_key }

    it { is_expected.to eq('request_time') }
  end
end
