require 'spec_helper'

describe PigCI::Report::Memory do
  let(:report) { PigCI::Report::Memory.new }

  describe '::format_row' do
    subject { PigCI::Report::Memory.format_row(row) }
    let(:row) do
      {
        max: 1048576,
        mean: 1048576,
        min: 1048576,
        total: 1048576,
        number_of_requests: 1,
        max_change_percentage: 0.0
      }
    end

    it do
      is_expected.to eq (
        {
          max: BigDecimal(1),
          mean: BigDecimal(1),
          min: BigDecimal(1),
          total: BigDecimal(1),
          number_of_requests: 1,
          max_change_percentage: '0.0%'
        }
      )
    end
  end

  describe '::bytes_in_a_megabyte' do
    subject { PigCI::Report::Memory.bytes_in_a_megabyte }

    it { is_expected.to eq(BigDecimal(1048576)) }
  end

  describe '#i18n_scope' do
    subject { report.i18n_scope }

    it { is_expected.to eq('pig_ci.report.memory') }
  end
end
