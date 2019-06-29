# frozen_string_literal: true

require 'spec_helper'

describe PigCI::Metric::Historical do
  let(:historical_log_file) { File.join('spec', 'fixtures', 'files', 'profiler.json') }
  let(:metric_historical) { PigCI::Metric::Historical.new(historical_log_file: historical_log_file) }

  describe '#to_h' do
    subject { metric_historical.to_h }

    let(:expected_response) do
      { "100": {
        profiler: [
          { key: 'request-key', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18 },
          { key: 'request-key-2', max: 2, mean: 2, min: 2, number_of_requests: 1, total: 2 }
        ]
      } }
    end
    it { is_expected.to eq(expected_response) }
  end
end
