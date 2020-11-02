# bundles

## ruby installation, e.g. macOS
* This code is configured to use Ruby 2.7.2 by `.ruby-version`.  This will be respected by [rbenv](https://github.com/rbenv/rbenv).  You can edit this to reference a ruby version already installed without following the rest of this.
* Follow the instructions at [Homebrew](https://brew.sh/) to install Homebrew
* Use the command `brew install rbenv ruby-build` to install `rbenv` and [ruby-build](https://github.com/rbenv/ruby-build).

## installation of dependencies.
* `gem install bundler`, if [Bundler](https://bundler.io) is not installed.
* `bundle install` to install dependencies, that include `byebug`, `rake`, `rspec` and `rubocop`.

## testing
* `bundle exec rake` will run [RuboCop](https://github.com/rubocop-hq/rubocop) and [RSpec](https://rspec.info)
* `bundle exec rubocop` will run `RuboCop`
* `bundle exec rspec` will run `RSpec`

## program execution
*
