class PigCi::Rails
  def self.setup!
    Dir.mkdir(PigCi.tmp_directory) unless File.exists?(PigCi.tmp_directory)

    PigCi::Loggers::Memory.setup!
    PigCi::Loggers::Sql.setup!

    # Attach listeners
    attach_listeners!
  end

  def self.attach_listeners!
    ::ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |*args|
      PigCi::Loggers::Memory.touch_memory!
    end
    ::ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
      event = ActiveSupport::Notifications::Event.new *args

      PigCi::Loggers::Memory.append_row("#{event.payload[:controller]}##{event.payload[:action]}")
    end
  end

  def self.build_report!
    PigCi::Loggers::Memory.report!
  end
end
