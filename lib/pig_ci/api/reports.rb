# frozen_string_literal: true

class PigCI::Api::Reports < PigCI::Api
  def initialize(reports: [])
    @reports = reports
  end

  def share!
    self.class.post('/v1/reports',
                    base_uri: PigCI.api_base_uri,
                    verify: PigCI.api_verify_ssl,
                    body: payload,
                    headers: headers)
  rescue Net::OpenTimeout => e
    puts '[PigCI] Unable to connect to PigCI API: '
    puts e.inspect
  end

  private

  def payload
    {
      commit_sha1: PigCI.commit_sha1,
      head_branch: PigCI.head_branch,
      reports: @reports.collect { |report| report.to_payload_for(PigCI.run_timestamp) }
    }.to_json
  end
end
