# frozen_string_literal: true

require 'spec_helper'

describe PigCI::Metric::Current do
  let(:log_file) { File.join('spec', 'fixtures', 'files', 'profiler.txt') }
  let(:metric_current) { PigCI::Metric::Current.new(log_file: log_file) }

  describe '#to_h' do
    subject { metric_current.to_h }

    let(:expected_output) do
      [
        { key: 'request-key', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18 },
        { key: 'request-key-2', max: 2, mean: 2, min: 2, number_of_requests: 1, total: 2 }
      ]
    end

    it { is_expected.to eq(expected_output) }
  end
end
