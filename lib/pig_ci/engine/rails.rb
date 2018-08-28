class PigCi::Engine::Rails < PigCi::Engine
  def self.profilers
    [
      PigCi::Profiler::Memory,
      PigCi::Profiler::InstantiationActiveRecord,
      PigCi::Profiler::SqlActiveRecord
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

    profilers.collect(&:setup!)

    # Attach listeners to the rails events.
    attach_listeners!
  end

  def self.attach_listeners!
    ::ActiveSupport::Notifications.subscribe 'start_processing.action_controller' do |*args|
      event = ActiveSupport::Notifications::Event.new *args
      self.request_key = "#{event.payload[:method]} #{event.payload[:controller]}##{event.payload[:action]}{format:#{event.payload[:format]}}"

      profilers.collect(&:start!)
    end

    ::ActiveSupport::Notifications.subscribe 'instantiation.active_record' do |*args|
      if self.request_key
        event = ActiveSupport::Notifications::Event.new *args
        PigCi::Profiler::InstantiationActiveRecord.increment!(by: event.payload[:record_count])
      end
    end

    ::ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
      if self.request_key
        # event = ActiveSupport::Notifications::Event.new *args
        PigCi::Profiler::SqlActiveRecord.increment!
      end
    end

    ::ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
      PigCi::Profiler::Memory.append_row(self.request_key)
      PigCi::Profiler::InstantiationActiveRecord.append_row(self.request_key)
      PigCi::Profiler::SqlActiveRecord.append_row(self.request_key)

      PigCi::Profiler::Memory.complete!
      self.request_key = nil
    end
  end
end
