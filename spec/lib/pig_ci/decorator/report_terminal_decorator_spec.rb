# frozen_string_literal: true

require 'spec_helper'

describe PigCI::Decorator::ReportTerminalDecorator do
  let(:object) do
    {
      key: 'request-key',
      min: 1,
      max: 1,
      mean: 2,
      number_of_requests: 1,
      max_change_percentage: '0.0%'
    }
  end
  let(:decorator) { PigCI::Decorator::ReportTerminalDecorator.new(object) }

  describe '#key' do
    subject { decorator.key }

    it { is_expected.to eq('request-key') }
  end

  describe '#max_change_percentage' do
    subject { decorator.max_change_percentage }

    it { is_expected.to eq('0.0%') }

    context 'minus result' do
      let(:object) do
        {
          max_change_percentage: '-4.0%'
        }
      end

      it { is_expected.to eq("\e[0;32;49m-4.0%\e[0m") }
    end

    context 'minus result' do
      let(:object) do
        {
          max_change_percentage: '4.0%'
        }
      end

      it { is_expected.to eq("\e[0;31;49m4.0%\e[0m") }
    end
  end
end
