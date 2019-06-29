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

  describe '#append!' do
    let(:timestamp) { '101' }
    let(:metric) { 'profiler' }
    let(:data) do
      [
        { key: 'request-key-3', max: 2, mean: 2, min: 2, number_of_requests: 1, total: 2 }
      ]
    end

    let(:new_data_as_json) do
      {
        "100": {
          profiler: [
            { key: 'request-key', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18 },
            { key: 'request-key-2', max: 2, mean: 2, min: 2, number_of_requests: 1, total: 2 }
          ]
        },
        "101": {
          profiler: [
            { key: 'request-key-3', max: 2, mean: 2, min: 2, number_of_requests: 1, total: 2 }
          ]
        }
      }.to_json
    end

    subject { metric_historical.append!(timestamp: timestamp, metric: metric, data: data) }

    it 'updates the hash, and saves the file to disk' do
      expect(File).to receive(:write).once do |file, new_data|
        expect(file).to eq(historical_log_file)
        expect(JSON.parse(new_data)).to eq(JSON.parse(new_data_as_json))
      end

      subject
    end
  end
end
