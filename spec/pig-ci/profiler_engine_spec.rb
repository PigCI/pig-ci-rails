require 'spec_helper'

describe PigCI::ProfilerEngine do
  let(:profiler_engine) { PigCI::ProfilerEngine.new }

  describe '#request_key' do
    subject { profiler_engine.request_key }

    it do
      profiler_engine.request_key = 'some-key'
      is_expected.to eq('some-key')
    end
  end

  describe '#request_key?' do
    subject { profiler_engine.request_key? }

    it do
      expect { profiler_engine.request_key = 'some-key' }.to change(profiler_engine, :request_key?).from(false).to(true)
    end
  end

  describe '#profilers' do
    subject { profiler_engine.profilers }

    it { is_expected.to eq([]) }
  end

  describe '#reports' do
    subject { profiler_engine.reports }

    it { is_expected.to eq([]) }
  end

  describe '#setup!' do
    subject { profiler_engine.setup! }

    it { expect { subject }.to raise_error(NotImplementedError) }
  end
end
