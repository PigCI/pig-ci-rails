class PigCi::Api::ShareReports < PigCi::Api
  def initialize(reports: [])
    @reports = reports
  end

  def share
    begin
      self.class.post('/reports', {
        base_uri: PigCi.api_base_uri,
        body: {
          commit_sha1: PigCi.commit_sha1, 
          reporter_name: PigCi.reporter_name, 
          reports: @reports.collect(&:to_json)
        },
        headers: headers
      })
    rescue
      puts '[PigCi] Unable to connect to PigCi API'
    end
  end
end
