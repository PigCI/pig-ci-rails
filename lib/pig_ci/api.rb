require 'httparty'

class PigCI::Api
  include HTTParty

  def headers
    {
      'X-ApiKey': PigCI.api_key
    }
  end
end

require 'pig_ci/api/reports'
