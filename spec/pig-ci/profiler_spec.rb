require 'spec_helper'

describe PigCI::Profiler do
  let(:pig_ci_profiler) { PigCI::Profiler.new }

  describe '#setup!' do
    subject { pig_ci_profiler.setup! }

    it 'clears the previous run data' do
      # Write some blank data
      File.write(pig_ci_profiler.log_file, 'some-data')

      expect { subject }.to change(pig_ci_profiler.log_file, :read).from('some-data').to('')
    end
  end

  describe '#reset!' do
    subject { pig_ci_profiler.reset! }

    it 'clears the log value' do
      pig_ci_profiler.log_value = 'some-value'

      expect { subject }.to change(pig_ci_profiler, :log_value).from('some-value').to(nil)
    end
  end

  describe '#save!(request_key)' do
    before { pig_ci_profiler.save!('request-key') }

    it 'saves the log value with the request key' do
      pig_ci_profiler.log_value = 23
      
      expect { subject }.to change(pig_ci_profiler.log_file, :read).from('').to('request-key|23')
    end
  end

  describe '#i18n_key' do
    subject { pig_ci_profiler.i18n_key }

    it { is_expected.to eq('pig_ci/profiler') }
  end
end
