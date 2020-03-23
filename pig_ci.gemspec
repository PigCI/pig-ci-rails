lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pig_ci/version'

Gem::Specification.new do |spec|
  spec.name          = 'pig-ci-rails'
  spec.version       = PigCI::VERSION
  spec.authors       = ['Mike Rogers']
  spec.email         = ['me@mikerogers.io']

  spec.summary       = 'Mintor metrics such a memory usage as part of testing'
  spec.description   = 'A gem for Ruby on Rails that will report key metrics (memory, request time & SQL Requests) for request & feature tests.'
  spec.homepage      = 'https://github.com/PigCI/pig-ci-rails'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3'

  spec.add_dependency 'activesupport', '>= 4.2'
  spec.add_dependency 'colorize', '>= 0.8.1'
  spec.add_dependency 'get_process_mem', '~> 0.2.3'
  spec.add_dependency 'httparty', '>= 0.16'
  spec.add_dependency 'i18n', '>= 0.9', '< 2'
  spec.add_dependency 'rails', '>= 4.2.0'
  spec.add_dependency 'terminal-table', '~> 1.8.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'webmock', '~> 3.8.0'

  spec.add_development_dependency 'json-schema', '~> 2.8.1'
  spec.add_development_dependency 'rspec', '~> 3.9.0'
  spec.add_development_dependency 'simplecov', '~> 0.17.0'
  spec.add_development_dependency 'yard', '~> 0.9.24'

  spec.post_install_message = [
    'Thank you for installing Pig CI!',
    'Upgrade Notes:',
    'The latest version adds a "config.thresholds" option which will replace the pigci.com integration in future.',
    'See https://github.com/PigCI/pig-ci-rails#configuring-thresholds for more information :)'
  ].join("\n")
end
