<h1 align="center">
  PigCI
</h1>

<p align="center">
Monitor your Ruby Applications metrics (Memory, SQL Requests & Request Time) as part of your test suite. If your app exceeds an acceptable threshold it'll fail the test suite.
</p>

<p align="center">
  <a target="_blank" rel="noopener noreferrer" href="https://badge.fury.io/rb/pig-ci-rails">
    <img src="https://badge.fury.io/rb/pig-ci-rails.svg" alt="Gem Version" style="max-width:100%;">
  </a>
  <a target="_blank" rel="noopener noreferrer" href="https://github.com/PigCI/pig-ci-rails/workflows/RSpec/badge.svg">
    <img src="https://github.com/PigCI/pig-ci-rails/workflows/RSpec/badge.svg" alt="RSpec" style="max-width:100%;">
  </a>
  <a target="_blank" rel="noopener noreferrer" href="https://github.com/PigCI/pig-ci-rails/workflows/Linters/badge.svg">
    <img src="https://github.com/PigCI/pig-ci-rails/workflows/Linters/badge.svg" alt="Linters" style="max-width:100%;">
  </a>
</p>


## Deprecation notice

This gem is not longer actively maintained, I suggest using theses alternatives instead:

- [TestProf](https://github.com/test-prof/test-prof)
- [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)
- [RSpec::Benchmark](https://github.com/piotrmurach/rspec-benchmark)

## Sample Output

![Sample Output of PigCI in TravisCI](https://user-images.githubusercontent.com/325384/78711087-545b6400-790e-11ea-96b7-bb75c119914a.png)

## Installation

Add this line to your application's Gemfile:

```ruby
group :test do
  gem 'pig-ci-rails'
end
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install pig-ci-rails
```

## Usage

### On it's own

```ruby
# In spec/rails_helper.rb
require 'pig_ci'
PigCI.start
```

### Configuring thresholds

Configuring the thresholds will allow your test suite to fail in CI. You will need to configure the thresholds depending on your application.

```ruby
# In spec/rails_helper.rb
require 'pig_ci'
PigCI.start do |config|
  # Maximum memory in megabytes
  config.thresholds.memory = 350

  # Maximum time per a HTTP request
  config.thresholds.request_time = 250

  # Maximum database calls per a request
  config.thresholds.database_request = 35
end if RSpec.configuration.files_to_run.count > 1
```

### Configuring other options

This gems was setup to be configured by passing a block to the `PigCI.start` method, e.g:

```ruby
# In spec/rails_helper.rb
require 'pig_ci'
PigCI.start do |config|
  config.option = 'new_value'

  # E.g. disable terminal summary output
  config.generate_terminal_summary = false

  # Rails caches repeated SQL queries, you might want to omit these from your report.
  config.ignore_cached_queries = true
end # if RSpec.configuration.files_to_run.count > 1
```

You can see the full configuration options [lib/pig_ci.rb](https://github.com/PigCI/pig-ci-rails/blob/master/lib/pig_ci.rb#L21).

### Skipping individual tests

If you have a scenario where you'd like PigCI to not log a specific test, you can add the RSpec metadata `pig_ci: true`. For example:

```ruby
RSpec.describe "Comments", type: :request do
  # This test block will be not be tracked.
  describe "GET #index", pig_ci: false do
    it do
      get comments_path
      expect(response).to be_successful
    end
  end
end
```

### Framework support

Currently this gem only supports Ruby on Rails tested via RSpec.

### Metric notes

Minor fluctuations in memory usage and request time are to be expected and are nothing to worry about. Though any large spike is a signal of something worth investigating.

#### Memory

By default, this gem will tell Rails to eager load your application on startup. This aims to help identify leaks, over just pure bulk.

You can disable this functionality by setting your configuration to be:

```ruby
require 'pig_ci'
PigCI.start do |config|
  config.during_setup_eager_load_application = false
end
```

#### Request Time

Often the first request test will be slow, as rails is loading a full environment & rendering assets. To mitigate this issue, this gem will make a blank request to your application before your test suite starts & compiling assets.

You can disable this functionality by setting your configuration to be:

```ruby
require 'pig_ci'
PigCI.start do |config|
  config.during_setup_make_blank_application_request = false
  config.during_setup_precompile_assets = false
end
```

## Authors

* This gem was made by [@MikeRogers0](https://github.com/MikeRogers0).
* It was originally inspired by [oink](https://github.com/noahd1/oink), after it was used to [monitor acceptance tests](https://mikerogers.io/2015/03/28/monitor-rails-memory-usage-in-integration-tests.html) and it spotted a memory leak. It seemed like something that would be useful to have as part of CI.
* The HTML output was inspired by [simplecov](https://github.com/colszowka/simplecov).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [PigCI/pig-ci-rails](https://github.com/PigCI/pig-ci-rails). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the PigCI project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/PigCI/pig-ci-rails/blob/master/CODE_OF_CONDUCT.md).
