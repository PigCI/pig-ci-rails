[![Gem Version](https://badge.fury.io/rb/pig-ci-rails.svg)](https://badge.fury.io/rb/pig-ci-rails)
[![Build Status](https://travis-ci.org/PigCI/pig-ci-rails.svg?branch=master)](https://travis-ci.org/PigCI/pig-ci-rails)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/a3ab882cc57c4cc68d7e30f25cad2568)](https://www.codacy.com/app/MikeRogers0/pig-ci-rails?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=PigCI/pig-ci-rails&amp;utm_campaign=Badge_Grade)
[![Maintainability](https://api.codeclimate.com/v1/badges/d022db58c712d425dba9/maintainability)](https://codeclimate.com/github/PigCI/pig-ci-rails/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/d022db58c712d425dba9/test_coverage)](https://codeclimate.com/github/PigCI/pig-ci-rails/test_coverage)

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

### With [PigCI.com](https://pigci.com) - For sharing runs as a team via CI

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
end # if ENV['RUN_PIG_CI'] || RSpec.configuration.files_to_run.count > 1
```

You can see the full configuration options [lib/pig_ci.rb](https://github.com/PigCI/pig-ci-rails/blob/master/lib/pig_ci.rb#L21).

### Framework support

Currently this gem only supports Ruby on Rails.

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

Often the first request test will be slow, as rails is loading a full environment. To mitigate this issue, this gem will make a blank request to your application before your test suite starts.

You can disable this functionality by setting your configuration to be:

```ruby
require 'pig_ci'
PigCI.start do |config|
  config.during_setup_make_blank_application_request = false
end
```

## Authors

* This gem was made by [@MikeRogers0](https://github.com/MikeRogers0).
* It was originally inspired by [oink](https://github.com/noahd1/oink), after it was used to [monitor acceptance tests](https://mikerogers.io/2015/03/28/monitor-rails-memory-usage-in-integration-tests.html) and it spotted a memory leak. It seemed like something that would be useful to have as part of CI.
* The HTML output was inspired by [simplecov](https://github.com/colszowka/simplecov).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODO

Features I'd like to add at some point:
 
* HTML output to include branch - Right now they're just timestamps which makes filtering hard.
* Should I disable terminal output by default? It feels like noise.
* Should I reject database requests that have a value of 0? I think so.
* Document setting branch/commit encase of weird CI.
* Add rake rake for submitting reports.

## Contributing

Bug reports and pull requests are welcome on GitHub at [PigCI/pig-ci-rails](https://github.com/PigCI/pig-ci-rails). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the PigCI project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/PigCI/pig-ci-rails/blob/master/CODE_OF_CONDUCT.md).
