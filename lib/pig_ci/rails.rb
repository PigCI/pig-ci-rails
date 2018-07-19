class PigCi::Rails
  def self.purge_previous_snapshots!
    Dir.mkdir(PigCi.tmp_directory) unless File.exists?(PigCi.tmp_directory)

    PigCi::Loggers::Memory.purge_previous_snapshot!
    PigCi::Loggers::Sql.purge_previous_snapshot!
  end

  def self.attach_listeners!
    ::ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
      event = ActiveSupport::Notifications::Event.new *args

      PigCi::Loggers::Memory.append_row("#{event.payload[:controller]}##{event.payload[:action]}")
    end
  end

  def self.build_report!
    PigCi::Loggers::Memory.report!
  end
end
