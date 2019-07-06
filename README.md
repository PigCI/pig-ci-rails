# PigCI

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/pig_ci`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## TODO

* HTML output to include branch & Quick navigate

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pig_ci'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pig_ci

## Usage

### On it's own

    # In spec/rails_helper.rb
    require 'pig_ci'
    PigCI.start

### With PigCI.com - For sharing runs as a team via CI.

    # In spec/rails_helper.rb
    require 'pig_ci'
    PigCI.start do |config|
      config.api_key = 'gClHJNkudAUYT7zrQ8cL7HBgOofqwaeQ1Ne7FjG9LD0'
    end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pig_ci. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the PigCI project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/pig_ci/blob/master/CODE_OF_CONDUCT.md).
