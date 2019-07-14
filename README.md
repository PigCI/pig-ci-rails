# PigCI

Monitor your Ruby Applications metrics (Memory, SQL Requests & Request Time) as part of your test suite.

Please consider supporting this project by adding [PigCI](https://pigci.com/) to your GitHub project & using this as part of CI. The CI tool will fail PRs that exceed metric threshold (e.g. a big increase in memory).

## TODO

  * HTML output to include branch - Right now they're just timestamps.
      
  * Replace out text outputs with I18n - I want to make this gem as accessible to non-English speakers as possible.
  * Change gem name to be `pig-ci-rails` - I want to support other frameworks, but while I figure out if people want this I want focus on Ruby on Rails because I'm familiar with it.
  * Make possible to turn off terminal output / report sharing.

## Installation

Add this line to your application's Gemfile:

```ruby
group :development, :test do
  gem 'pig-ci'
end
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install pig_ci
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
end
```

You can see the full configuration options [lib/pig_ci.rb](https://github.com/PigCI/pig-ci-ruby/blob/master/lib/pig_ci.rb#L21).

### Framework support

Currently this gem only support the Rails gem.

### Metric notes

#### Memory & Request Time

Minor fluctuations in memory usage and request time are to be expected and are nothing to worry about. Though any large spike is a signal of something worth investigating.

## Authors

  * This gem was made by [@MikeRogers0](https://github.com/MikeRogers0).
  * It was originally inspired by [oink](https://github.com/noahd1/oink), after it was used to [monitor acceptance tests](https://mikerogers.io/2015/03/28/monitor-rails-memory-usage-in-integration-tests.html) and it spotted a memory leak. It seemed like something that would be useful to have as part of CI.
  * The HTML output was inspired by [simplecov](https://github.com/colszowka/simplecov).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PigCI/pig-ci-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the PigCI project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/PigCI/pig-ci-ruby/blob/master/CODE_OF_CONDUCT.md).
