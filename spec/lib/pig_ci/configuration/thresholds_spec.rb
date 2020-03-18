require 'spec_helper'

describe PigCI::Configuration::Thresholds do
  let(:instance_class) { described_class.new }

  describe '::new' do
    subject { described_class.new }

    it 'has default values' do
      expect(subject.memory).to eq(350)
      expect(subject.request_time).to eq(250)
      expect(subject.database_request).to eq(35)
    end

    context 'configured with a hash' do
      subject do
        described_class.new({
          memory: 300,
          request_time: 200,
          database_request: 25
        })
      end

      it do
        expect(subject.memory).to eq(300)
        expect(subject.request_time).to eq(200)
        expect(subject.database_request).to eq(25)
      end
    end
  end

  describe '#memory' do
    subject { instance_class.memory }
    it { is_expected.to eq(350) }
  end

  describe '#memory=' do
    subject { instance_class.memory = 200 }
    it { expect { subject }.to change(instance_class, :memory).from(350).to(200) }
  end

  describe '#dig' do
    subject { instance_class.dig(:memory) }
    it { is_expected.to eq(350) }
  end
end
