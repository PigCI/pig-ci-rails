# frozen_string_literal: true

class PigCI::Api::Reports < PigCI::Api
  def initialize(reports: [])
    @reports = reports
  end

  def share!
    response = post_payload
    return if response.success?

    puts I18n.t('pig_ci.api.reports.error', error: JSON.parse(response.parsed_response || '{}')['error'])
  rescue Net::OpenTimeout => e
    puts I18n.t('pig_ci.api.reports.error', error: e.inspect)
  end

  private

  def post_payload
    self.class.post(
      '/v1/reports',
      base_uri: PigCI.api_base_uri,
      verify: PigCI.api_verify_ssl,
      body: payload,
      headers: headers
    )
  end

  def payload
    {
      library: 'pig-ci-rails',
      library_version: PigCI::VERSION,
      commit_sha1: PigCI.commit_sha1,
      head_branch: PigCI.head_branch,
      reports: @reports.collect { |report| report.to_payload_for(PigCI.run_timestamp) }
    }.to_json
  end
end
