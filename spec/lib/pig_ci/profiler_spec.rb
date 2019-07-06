# frozen_string_literal: true

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

    it { expect { subject }.to raise_error(NotImplementedError) }
  end

  describe '#log_request!(request_key)' do
    subject { profiler.log_request!('request-key') }

    before { profiler.setup! }

    it 'saves the log value with the request key' do
      profiler.log_value = 23

      expect { subject }.to change(profiler.log_file, :read).from('').to("request-key|23\n")
    end
  end

  describe '#log_file' do
    subject { profiler.log_file.to_s }

    it { is_expected.to match('profiler.txt') }

    context 'can be defined on initialize' do
      let(:profiler) { PigCI::Profiler.new(log_file: 'something-else') }

      it { is_expected.to eq('something-else') }
    end
  end

  describe '#historical_log_file' do
    subject { profiler.historical_log_file.to_s }

    it { is_expected.to match('profiler.json') }

    context 'can be defined on initialize' do
      let(:profiler) { PigCI::Profiler.new(historical_log_file: 'something-else') }

      it { is_expected.to eq('something-else') }
    end
  end

  describe '#i18n_key' do
    subject { profiler.i18n_key }

    it { is_expected.to eq('profiler') }

    context 'can be defined on initialize' do
      let(:profiler) { PigCI::Profiler.new(i18n_key: 'something-else') }

      it { is_expected.to eq('something-else') }
    end
  end

  describe '#save!' do
    subject { profiler.save! }

    let(:expected_output) { JSON.parse(File.open(File.join('spec', 'fixtures', 'files', 'profiler.json')).read) }

    before do
      profiler.log_file = File.join('spec', 'fixtures', 'files', 'profiler.txt')
      File.write(profiler.historical_log_file, '{}')
    end

    it 'takes the profiler data, and saves in a JSON format with previous test runs' do
      expect { subject }.to change { JSON.parse(profiler.historical_log_file.read) }.from({}).to(expected_output)
    end
  end
end
