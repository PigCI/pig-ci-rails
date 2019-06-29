class PigCI::ProfilerEngine::Rails < ::PigCI::ProfilerEngine
  def self.profilers
    [
      PigCI::Profiler::Memory,
      PigCI::Profiler::InstantiationActiveRecord,
      PigCI::Profiler::RequestTime,
      PigCI::Profiler::SqlActiveRecord
    ]
  end

  def self.reports
    [
      PigCI::Report::Memory,
      PigCI::Report::InstantiationActiveRecord,
      PigCI::Report::RequestTime,
      PigCI::Report::SqlActiveRecord
    ]
  end

  def self.setup!
    Dir.mkdir(PigCI.tmp_directory) unless File.exists?(PigCI.tmp_directory)

    profilers.collect(&:setup!)

    # Attach listeners to the rails events.
    attach_listeners!
  end

  def self.attach_listeners!
    ::ActiveSupport::Notifications.subscribe 'start_processing.action_controller' do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      self.request_key = PigCI.request_key(event.payload)

      profilers.collect(&:start!)
    end

    ::ActiveSupport::Notifications.subscribe 'instantiation.active_record' do |*args|
      if self.request_key
        event = ActiveSupport::Notifications::Event.new(*args)
        PigCI::Profiler::InstantiationActiveRecord.increment!(by: event.payload[:record_count])
      end
    end

    ::ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
      if self.request_key
        # event = ActiveSupport::Notifications::Event.new *args
        PigCI::Profiler::SqlActiveRecord.increment!
      end
    end

    ::ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      PigCI::Profiler::RequestTime.stop!

      profilers.each do |profiler|
        profiler.append_row(request_key)
      end
      PigCI.request_was_completed = true
      self.request_key = nil
    end
  end
end
