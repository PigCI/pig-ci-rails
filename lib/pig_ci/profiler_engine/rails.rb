# This subscribes to the ActiveSupport::Notifications and passes it onto our profilers.
class PigCI::ProfilerEngine::Rails < ::PigCI::ProfilerEngine
  def profilers
    @profilers ||= [
      PigCI::Profiler::Memory.new,
      PigCI::Profiler::InstantiationActiveRecord.new,
      PigCI::Profiler::RequestTime.new,
      PigCI::Profiler::SqlActiveRecord.new
    ]
  end

  def reports
    @reports ||= [
      PigCI::Report::Memory.new,
      PigCI::Report::InstantiationActiveRecord.new,
      PigCI::Report::RequestTime.new,
      PigCI::Report::SqlActiveRecord.new
    ]
  end

  private

  def payload_to_request_key(payload)
    @request_key = Proc.new{ |pl| "#{pl[:method]} #{pl[:controller]}##{pl[:action]}{format:#{pl[:format]}}" }.call(payload)
  end

  def attach_listeners!
    ::ActiveSupport::Notifications.subscribe 'start_processing.action_controller' do |name, started, finished, unique_id, payload|
      request_key = payload_to_request_key(payload)

      profilers.collect(&:start!)
    end

    ::ActiveSupport::Notifications.subscribe 'instantiation.active_record' do |name, started, finished, unique_id, payload|
      if request_key?
        PigCI::Profiler::InstantiationActiveRecord.increment!(by: payload[:record_count])
      end
    end

    ::ActiveSupport::Notifications.subscribe 'sql.active_record' do |name, started, finished, unique_id, payload|
      if request_key?
        PigCI::Profiler::SqlActiveRecord.increment!
      end
    end

    ::ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |name, started, finished, unique_id, payload|
      PigCI::Profiler::RequestTime.stop!

      profilers.each do |profiler|
        profiler.append_row(request_key)
      end

      PigCI.request_was_completed = true
      request_key = nil
    end
  end
end
