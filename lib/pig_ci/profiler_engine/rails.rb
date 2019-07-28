# This subscribes to the ActiveSupport::Notifications and passes it onto our profilers.
class PigCI::ProfilerEngine::Rails < ::PigCI::ProfilerEngine
  def initialize(profilers: nil, reports: nil)
    @profilers = profilers || [
      PigCI::Profiler::Memory.new,
      PigCI::Profiler::RequestTime.new,
      PigCI::Profiler::DatabaseRequest.new
    ]
    @reports = reports || [
      PigCI::Report::Memory.new,
      PigCI::Report::RequestTime.new,
      PigCI::Report::DatabaseRequest.new
    ]
    @request_captured = false
  end

  def request_key_from_payload!(payload)
    @request_key = "#{payload[:method]} #{payload[:controller]}##{payload[:action]}{format:#{payload[:format]}}"
  end

  def setup!
    super do
      eager_load_rails!
    end
  end

  private

  def eager_load_rails!
    # Eager load rails to give more accurate memory levels.
    ::Rails.application.eager_load!
    ::Rails::Engine.subclasses.map(&:instance).each(&:eager_load!)
    ::ActiveRecord::Base.descendants

    # Make a call to the root path to load up as much of rails as possible
    ::Rails.application.call(::Rack::MockRequest.env_for('/'))
  end

  def attach_listeners!
    ::ActiveSupport::Notifications.subscribe 'start_processing.action_controller' do |_name, _started, _finished, _unique_id, payload|
      request_key_from_payload!(payload)

      profilers.each(&:reset!)
    end

    ::ActiveSupport::Notifications.subscribe 'sql.active_record' do |_name, _started, _finished, _unique_id, _payload|
      if request_key?
        profilers.select { |profiler| profiler.class == PigCI::Profiler::DatabaseRequest }.each(&:increment!)
      end
    end

    ::ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |_name, _started, _finished, _unique_id, _payload|
      profilers.each do |profiler|
        profiler.log_request!(request_key)
      end

      request_captured!
      self.request_key = nil
    end
  end
end
