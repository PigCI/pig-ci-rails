require 'spec_helper'

describe PigCI::Decorator do
  let(:decorator) { PigCI::Decorator.new(object) }

  describe '#object' do
    let(:object) { double :object }
    subject { decorator.object }

    it { is_expected.to eq(object) }
  end
end
