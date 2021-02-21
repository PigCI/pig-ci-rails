class PigCI::Decorator
  attr_accessor :object

  def initialize(object)
    @object = object
  end
end

require "pig_ci/decorator/report_terminal_decorator"
