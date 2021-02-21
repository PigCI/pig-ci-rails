require "colorized_string"

class PigCI::Decorator::ReportTerminalDecorator < PigCI::Decorator
  %i[key max min mean number_of_requests].each do |field|
    define_method(field) do
      @object[field]
    end
  end

  def max_change_percentage
    if @object[:max_change_percentage].start_with?("-")
      ColorizedString[@object[:max_change_percentage]].colorize(:green)
    elsif @object[:max_change_percentage].start_with?("0.0")
      @object[:max_change_percentage]
    else
      ColorizedString[@object[:max_change_percentage]].colorize(:red)
    end
  end
end
