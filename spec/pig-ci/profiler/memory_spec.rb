require 'spec_helper'

describe PigCI::Profiler::Memory do
  let(:profiler) { PigCI::Profiler::Memory.new }

  describe '#reset!' do
    subject { profiler.reset! }

    it 'disables garbage collection' do
      expect(GC).to receive(:disable)
      subject
    end
  end

  describe '#log_request!(request_key)' do
    subject { profiler.log_request!('request-key') }
    let(:get_process_mem) { double :get_process_mem, bytes: 55 }

    before { profiler.setup! }

    it 'enables garbage collection, and saves memory to logs' do
      expect(GC).to receive(:enable)
      expect(GetProcessMem).to receive(:new).and_return(get_process_mem)

      expect { subject }.to change(profiler.log_file, :read).from('').to("request-key|55\n")
    end
  end

  describe '#i18n_key' do
    subject { profiler.i18n_key }

    it { is_expected.to eq('memory') }
  end
end
