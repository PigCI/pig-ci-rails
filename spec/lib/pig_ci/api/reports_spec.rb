require 'spec_helper'

describe PigCI::Api::Reports do
  let(:reports) do
    [
      PigCI::Report.new(i18n_key: 'memory', historical_log_file: File.join('spec', 'fixtures', 'files', 'memory.json'))
    ]
  end
  let(:api) { PigCI::Api::Reports.new(reports: reports) }
  before { PigCI.api_key = 'api-key' }
  after { PigCI.api_key = nil }

  describe '#share!' do
    subject { api.share! }

    context 'PigCI is offline' do
      before do
        stub_request(:post, 'https://api.pigci.com/v1/reports').to_timeout
      end

      it do
        expect { subject }.to output(/Unable to connect to PigCI API/).to_stdout
      end
    end

    context 'API key is invalid' do
      before do
        stub_request(:post, 'https://api.pigci.com/v1/reports')
          .to_return(status: 401, body: {
            error: 'API Key is invalid'
          }.to_json)
      end

      it do
        expect { subject }.to output(/API Key is invalid/).to_stdout
      end
    end

    context 'request is successful' do
      before do
        stub_request(:post, 'https://api.pigci.com/v1/reports')
          .to_return(status: 200)
      end

      it 'makes the API request with valid JSON as param' do
        subject
        expect(a_request(:post, 'https://api.pigci.com/v1/reports').with do |req|
          expect(req.body).to match_response_schema('pigci.com/v1/reports/schema')

          payload = JSON.parse(req.body)
          expect(payload['commit_sha1']).to eq('test_sha1')
          expect(payload['head_branch']).to eq('test/branch')
          expect(payload['reports']).to be_an(Array)
        end).to have_been_made
      end
    end
  end
end
