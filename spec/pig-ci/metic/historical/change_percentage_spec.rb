# frozen_string_literal: true

require 'spec_helper'

describe PigCI::Metric::Historical::ChangePercentage do
  let(:change_percentage) { PigCI::Metric::Historical::ChangePercentage.new(previous_data: previous_data, data: data) }

  let(:data) do
    {
      '101' => {
        profiler: [
          { key: 'request-key', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18 },
        ]
      }
    }
  end

  describe '#updated_data' do
    subject { change_percentage.updated_data }

    context 'no previous data' do
      let(:previous_data) { {} }
      let(:expected_response) do
        {
          '101' => {
            profiler: [
              { key: 'request-key', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18, max_change: 0 },
            ]
          }
        }
      end

      it { is_expected.to eq(expected_response) }
    end

    context 'previous for a different key' do
      let(:previous_data) do
        {
          '100' => {
            profiler: [
              { key: 'request-key-2', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18 },
            ]
          }
        }
      end
      let(:expected_response) do
        {
          '101' => {
            profiler: [
              { key: 'request-key', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18, max_change: 0 },
            ]
          }
        }
      end

      it { is_expected.to eq(expected_response) }
    end

    context 'previous data has run from a while back that matches' do
      let(:previous_data) do
        {
          '99' => {
            profiler: [
              { key: 'request-key', max: 24, mean: 24, min: 24, number_of_requests: 1, total: 24 },
            ]
          },
          '100' => {
            profiler: [
              { key: 'request-key-2', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18 },
            ]
          }
        }
      end
      let(:expected_response) do
        {
          '101' => {
            profiler: [
              { key: 'request-key', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18, max_change: 0 },
            ]
          }
        }
      end

      it { is_expected.to eq(expected_response) }
    end

    context 'data is lower previous value' do
      let(:previous_data) do
        {
          '100' => {
            profiler: [
              { key: 'request-key', max: 24, mean: 24, min: 24, number_of_requests: 1, total: 24 },
            ]
          }
        }
      end
      let(:expected_response) do
        {
          '101' => {
            profiler: [
              { key: 'request-key', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18, max_change: -0.5 },
            ]
          }
        }
      end

      it { is_expected.to eq(expected_response) }
    end

    context 'data is higher previous value' do
      let(:previous_data) do
        {
          '100' => {
            profiler: [
              { key: 'request-key', max: 6, mean: 6, min: 6, number_of_requests: 1, total: 6 },
            ]
          }
        }
      end
      let(:expected_response) do
        {
          '101' => {
            profiler: [
              { key: 'request-key', max: 12, mean: 9, min: 6, number_of_requests: 2, total: 18, max_change: 50 },
            ]
          }
        }
      end

      it { is_expected.to eq(expected_response) }
    end
  end
end
