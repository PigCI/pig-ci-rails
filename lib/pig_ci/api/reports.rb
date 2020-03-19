class PigCI::Api::Reports < PigCI::Api
  def initialize(reports: [])
    @reports = reports
  end

  def share!
    response = post_payload
    if response.success?
      puts I18n.t('pig_ci.api.reports.success')
      return
    end

    if response.parsed_response.is_a?(Hash)
      puts I18n.t('pig_ci.api.reports.error', error: response.parsed_response.dig('error'))
    else
      puts I18n.t('pig_ci.api.reports.error')
    end
  rescue JSON::ParserError => _e
    puts I18n.t('pig_ci.api.reports.api_error')
  rescue SocketError => e
    puts I18n.t('pig_ci.api.reports.error', error: e)
  rescue Net::OpenTimeout => e
    puts I18n.t('pig_ci.api.reports.error', error: e.inspect)
  end

  private

  def post_payload
    self.class.post(
      '/v1/reports',
      base_uri: PigCI.api_base_uri,
      verify: PigCI.api_verify_ssl?,
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
