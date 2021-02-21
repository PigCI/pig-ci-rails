class PigCI::Configuration
  Thresholds = Struct.new(:memory, :request_time, :database_request) {
    def initialize(memory: 350, request_time: 250, database_request: 35)
      super(memory, request_time, database_request)
    end
  }
end
