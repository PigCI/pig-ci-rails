class PigCI::Api::Reports < PigCI::Api
  def initialize(reports: [])
    @reports = reports
  end

  def share!
    begin
      self.class.post('/v1/reports', {
                        base_uri: PigCI.api_base_uri,
                        verify: PigCI.api_verify_ssl,
                        body: {
                          commit_sha1: PigCI.commit_sha1,
                          head_branch: PigCI.head_branch,
                          reports: @reports.collect { |report| report.to_json_for(PigCI.run_timestamp) }
                        },
                        headers: headers
                      })
    rescue => e
      puts '[PigCI] Unable to connect to PigCI API: '
      puts e.inspect
    end
  end
end
