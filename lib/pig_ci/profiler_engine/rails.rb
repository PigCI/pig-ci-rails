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
      precompile_assets! if PigCI.during_setup_precompile_assets?
      eager_load_rails! if PigCI.during_setup_eager_load_application?
      make_blank_application_request! if PigCI.during_setup_make_blank_application_request?
    end
  end

  private

  def precompile_assets!
    # From: https://github.com/rails/sprockets-rails/blob/e9ca63edb6e658cdfcf8a35670c525b369c2ccca/test/test_railtie.rb#L7-L13
    ::Rails.application.load_tasks
    ::Rake.application["assets:precompile"].execute
  end

  def eager_load_rails!
    # None of these methods will work pre-rails 5.
    return unless ::Rails.version.to_f >= 5.0

    # Eager load rails to give more accurate memory levels.
    ::Rails.application.eager_load!
    ::Rails.application.routes.eager_load!
    ::Rails::Engine.subclasses.map(&:instance).each(&:eager_load!)
    ::ActiveRecord::Base.descendants
  end

  def make_blank_application_request!
    # Make a call to the root path to load up as much of rails as possible
    # Done within a timezone block as it affects the timezone.
    Time.use_zone("UTC") do
      ::Rails.application.call(::Rack::MockRequest.env_for("/"))
    end
  end

  def attach_listeners!
    ::ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |_name, _started, _finished, _unique_id, payload|
      request_key_from_payload!(payload)

      profilers.each(&:reset!)
    end

    ::ActiveSupport::Notifications.subscribe "sql.active_record" do |_name, _started, _finished, _unique_id, payload|
      if request_key? && PigCI.enabled? && (!PigCI.ignore_cached_queries? || (PigCI.ignore_cached_queries? && !payload[:cached]))
        profilers.select { |profiler| profiler.instance_of?(PigCI::Profiler::DatabaseRequest) }.each(&:increment!)
      end
    end

    ::ActiveSupport::Notifications.subscribe "process_action.action_controller" do |_name, _started, _finished, _unique_id, _payload|
      if PigCI.enabled?
        profilers.each do |profiler|
          profiler.log_request!(request_key)
        end

        request_captured!
      end
      self.request_key = nil
    end
  end
end
