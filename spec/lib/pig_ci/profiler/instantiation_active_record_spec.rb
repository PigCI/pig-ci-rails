# frozen_string_literal: true

require 'spec_helper'

describe PigCI::Profiler::InstantiationActiveRecord do
  let(:profiler) { PigCI::Profiler::InstantiationActiveRecord.new }

  describe '#increment!' do
    subject { profiler.increment! }

    it { expect { subject }.to change(profiler, :log_value).by(1) }

    context 'with by argument' do
      subject { profiler.increment!(by: 2) }

      it { expect { subject }.to change(profiler, :log_value).by(2) }
    end
  end

  describe '#i18n_key' do
    subject { profiler.i18n_key }

    it { is_expected.to eq('instantiation_active_record') }
  end
end
