class PigCi::Rails
  def self.loggers
    [
      PigCi::Logger::Memory,
      PigCi::Logger::InstantiationActiveRecord,
      PigCi::Logger::SqlActiveRecord
    ]
  end

  def self.reports
    [
      PigCi::Report::Memory,
      PigCi::Report::InstantiationActiveRecord,
      PigCi::Report::SqlActiveRecord
    ]
  end

  def self.setup!
    Dir.mkdir(PigCi.tmp_directory) unless File.exists?(PigCi.tmp_directory)

    loggers.collect(&:setup!)

    # Attach listeners
    attach_listeners!
  end

  def self.request_key
    @request_key
  end

  def self.request_key=(value)
    @request_key = value
  end

  def self.attach_listeners!
    ::ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |*args|
      event = ActiveSupport::Notifications::Event.new *args
      self.request_key = "#{event.payload[:method]} #{event.payload[:controller]}##{event.payload[:action]}{format:#{event.payload[:format]}}"

      loggers.collect(&:start!)
    end

    ::ActiveSupport::Notifications.subscribe "instantiation.active_record" do |*args|
      if self.request_key
        event = ActiveSupport::Notifications::Event.new *args
        PigCi::Logger::InstantiationActiveRecord.increment!(by: event.payload[:record_count])
      end
    end

    ::ActiveSupport::Notifications.subscribe "sql.active_record" do |*args|
      if self.request_key
        event = ActiveSupport::Notifications::Event.new *args
        PigCi::Logger::SqlActiveRecord.increment!
      end
    end

    ::ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
      event = ActiveSupport::Notifications::Event.new *args
      PigCi::Logger::Memory.append_row(self.request_key)
      PigCi::Logger::InstantiationActiveRecord.append_row(self.request_key)
      PigCi::Logger::SqlActiveRecord.append_row(self.request_key)

      PigCi::Logger::Memory.complete!
      self.request_key = nil
    end
  end
end
