class PigCI::TestFrameworks::Rspec
  def self.configure!
    if defined?(::RSpec)
      ::RSpec.configure do |config|
        config.around(:each, pig_ci: false) do |example|
          @pig_ci_enabled = PigCI.enabled?
          PigCI.enabled = false
          example.run
          PigCI.enabled = @pig_ci_enabled
        end

        config.around(:each, pig_ci: true) do |example|
          @pig_ci_enabled = PigCI.enabled?
          PigCI.enabled = true
          example.run
          PigCI.enabled = @pig_ci_enabled
        end
      end
    end
  end
end
