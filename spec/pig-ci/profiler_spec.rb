require 'spec_helper'

describe PigCI::Profiler do
  let(:profiler) { PigCI::Profiler.new }

  describe '#setup!' do
    subject { profiler.setup! }

    it 'clears the previous run data' do
      # Write some blank data
      File.write(profiler.log_file, 'some-data')

      expect { subject }.to change(profiler.log_file, :read).from('some-data').to('')
    end
  end

  describe '#reset!' do
    subject { profiler.reset! }

    it 'clears the log value' do
      profiler.log_value = 12

      expect { subject }.to change(profiler, :log_value).from(12).to(0)
    end
  end

  describe '#increment!' do
    subject { profiler.increment! }

    it { expect { subject }.to raise_error(NotImplemented) }
  end

  describe '#save!(request_key)' do
    subject { profiler.save!('request-key') }

    before { profiler.setup! }

    it 'saves the log value with the request key' do
      profiler.log_value = 23
      
      expect { subject }.to change(profiler.log_file, :read).from('').to("request-key|23\n")
    end
  end

  describe '#log_file' do
    subject { profiler.log_file.to_s }

    it { is_expected.to match('profiler.txt') }
  end


  describe '#i18n_key' do
    subject { profiler.i18n_key }

    it { is_expected.to eq('profiler') }
  end
end
