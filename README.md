# PigCI

Monitor your Ruby Applications metrics (Memory, SQL Requests & Request Time) as part of your test suite.

Please consider supporting this project by adding [PigCI](https://pigci.com/) to your GitHub project & using this as part of CI. The CI tool will fail PRs that exceed metric threshold (e.g. a big increase in memory).

## Installation

Add this line to your application's Gemfile:

```ruby
group :test do
  gem 'pig-ci-rails'
end
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install pig-ci-rails
```

## Usage

### On it's own

```ruby
# In spec/rails_helper.rb
require 'pig_ci'
PigCI.start
```

### With [PigCI.com](https://pigci.com) - For sharing runs as a team via CI.

You can hookup your project to PigCI.com, this will fail PRs when metric thresholds are exceeded (e.g. your app see a big increase in memory).

```ruby
# In spec/rails_helper.rb
require 'pig_ci'
PigCI.start do |config|
  # When you connect your project, you'll be given an API key.
  config.api_key = 'you-api-key-here'
end
```

### Configuring PigCI

This gems was setup to be configured by passing a block to the `PigCI.start` method, e.g:

```ruby
# In spec/rails_helper.rb
require 'pig_ci'
PigCI.start do |config|
  config.option = 'new_value'

  # E.g. disable terminal summary output
  config.generate_terminal_summary = false
end # if RSpec.configuration.files_to_run.count > 1
```

You can see the full configuration options [lib/pig_ci.rb](https://github.com/PigCI/pig-ci-rails/blob/master/lib/pig_ci.rb#L21).

### Framework support

Currently this gem only supports Ruby on Rails.

### Metric notes

#### Memory

Minor fluctuations in memory usage and request time are to be expected and are nothing to worry about. Though any large spike is a signal of something worth investigating.

You can improve its accuracy by updating your `config/environments/test.rb` to have the line:

```ruby
config.eager_load = true
```

#### Request Time

Often the first request test will be slow, as rails is loading a full environment. While this metric is useful, I'd suggest focusing on other metrics (like memory, or database requests).

Alternatively add:

```ruby
Rails.application.call(::Rack::MockRequest.env_for('/'))
```

Before you call `PigCI.start`.

## Authors

  * This gem was made by [@MikeRogers0](https://github.com/MikeRogers0).
  * It was originally inspired by [oink](https://github.com/noahd1/oink), after it was used to [monitor acceptance tests](https://mikerogers.io/2015/03/28/monitor-rails-memory-usage-in-integration-tests.html) and it spotted a memory leak. It seemed like something that would be useful to have as part of CI.
  * The HTML output was inspired by [simplecov](https://github.com/colszowka/simplecov).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODO

Features I'd like to add at some point:
 
  * Codacy fixups
  * HTML output to include branch - Right now they're just timestamps which makes filtering hard.
  * Add the logo of PigCI to HTML summary.
  * Should I disable terminal output by default? It feels like noise.
  * Should I reject database requests that have a value of 0? I think so.
  * Share gem version and stuff back to PigCI.
  * Document setting branch/commit encase of weird CI.

## Contributing

Bug reports and pull requests are welcome on GitHub at [PigCI/pig-ci-rails](https://github.com/PigCI/pig-ci-rails). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the PigCI project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/PigCI/pig-ci-rails/blob/master/CODE_OF_CONDUCT.md).
