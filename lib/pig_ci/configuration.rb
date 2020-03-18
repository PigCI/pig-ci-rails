class PigCI::Configuration
  Thresholds = Struct.new(:memory, :request_time, :database_request, keyword_init: true) do
    def initialize(memory: 350, request_time: 250, database_request: 35)
      super
    end
  end
end
