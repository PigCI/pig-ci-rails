require 'httparty'

class PigCi::Api
  include HTTParty

  def headers
    {
      'X-ApiKey': PigCi.api_key
    }
  end
end

require 'pig_ci/api/share_reports'
