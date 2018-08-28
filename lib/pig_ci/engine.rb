class PigCi::Engine
  class << self
    attr_accessor :request_key
  end
end

require 'pig_ci/engine/rails'
