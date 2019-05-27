class PigCi::Api::ShareReports < PigCi::Api
  def initialize(reports: [])
    @reports = reports
  end

  def share
    begin
      self.class.post('/reports', {
        base_uri: PigCi.api_base_uri,
        verify: PigCi.api_verify_ssl,
        body: {
          commit_sha1: PigCi.commit_sha1, 
          head_branch: PigCi.head_branch, 
          reporter_name: PigCi.reporter_name, 
          reports: @reports.collect(&:to_json)
        },
        headers: headers
      })
    rescue => e
      puts '[PigCi] Unable to connect to PigCi API: '
      puts e.inspect
    end
  end
end
