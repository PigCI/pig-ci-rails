require 'spec_helper'

describe PigCI::Report do
  let(:report) { PigCI::Report.new }

  describe '::format_row' do
    subject { PigCI::Report.format_row(row) }
    let(:row) do
      {
        max: 1_048_576,
        mean: 1_048_576,
        min: 1_048_576,
        total: 1_048_576,
        number_of_requests: 1,
        max_change_percentage: 0.0
      }
    end

    it do
      is_expected.to eq(
        {
          max: 1_048_576,
          mean: 1_048_576,
          min: 1_048_576,
          total: 1_048_576,
          number_of_requests: 1,
          max_change_percentage: '0.0%'
        }
      )
    end
  end

  describe '#max_for' do
    subject { report.max_for('1000') }

    let(:rows) do
      [
        { max: 576 },
        { max: 1_048_576 },
        { max: 576 }
      ]
    end

    before do
      allow(report).to receive(:sorted_and_formatted_data_for).and_return(rows)
    end

    it { is_expected.to eq(1_048_576) }
  end

  describe '#i18n_scope' do
    subject { report.i18n_scope }

    it { is_expected.to eq('pig_ci.report.report') }
  end

  context 'i18n_key is memory' do
    let(:report) { PigCI::Report.new(i18n_key: 'memory') }

    describe '#i18n_name' do
      subject { report.i18n_name }

      it { is_expected.to eq('Peak memory per a request') }
    end

    describe '#headings' do
      subject { report.headings }

      it { is_expected.to eq(['Key', 'Max (MB)', 'Min (MB)', 'Mean (MB)', 'Requests', '% Change']) }
    end

    describe '#limit' do
      subject { report.limit }

      it { is_expected.to eq(350) }
    end
  end
end
