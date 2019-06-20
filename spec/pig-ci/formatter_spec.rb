require 'spec_helper'

describe PigCi::Formatter do
  let(:reports) do
    [
      PigCi::Report::Memory,
      PigCi::Report::InstantiationActiveRecord,
      PigCi::Report::RequestTime,
      PigCi::Report::SqlActiveRecord
    ]
  end
  subject { PigCi::Formatter.new(reports: reports) }

  describe '#save!' do
    it do
      expect { subject }.to_not raise_error
    end
  end
end
