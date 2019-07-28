require 'httparty'

class PigCI::Api
  include HTTParty

  def headers
    {
      'Content-Type': 'application/json',
      'X-ApiKey': PigCI.api_key
    }
  end
end

require 'pig_ci/api/reports'
