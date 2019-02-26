# Artemis ApiAuth
[![Build Status](https://travis-ci.org/JanStevens/artemis-api-auth.svg?branch=master)](https://travis-ci.org/JanStevens/artemis-api-auth)
[![Coverage Status](https://coveralls.io/repos/github/JanStevens/artemis-api-auth/badge.svg?branch=master)](https://coveralls.io/github/JanStevens/artemis-api-auth?branch=master)

This gem provides a new Adapter for the [Artemis](https://github.com/yuki24/artemis) GraphQL ruby client to support HMAC Authentication
using [ApiAuth](https://github.com/mgomes/api_auth)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'artemis-api_auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install artemis-api-auth-adapter

## Usage

After following the installation instruction of Artemis, update your `config/graphql.yml` to use the new `net_http_hmac` adapter

```yaml
default: &default
  # The underlying client library that actually makes an HTTP request.
  # Available adapters are :net_http, :net_http_persistent, :curb, and :test.
  #
  # It is set to :net_http by default.
  adapter: :net_http_hmac
```

You can configure ApiAuth by setting the `default_context` in your Artemis client

```ruby
class Artsy < Artemis::Client
  # Set the default context for HMAC authentication from the secrets
  # This will be used in our Net HTTP HMAC adapter
  # @see {Artemis::Adapters::NetHttpHmacAdapter}
  self.default_context = {
    api_auth: {
      access_id: '1',
      secret_key: 'very-secret-hmac-api-key',
      # optional
      digest: 'sha256', # default since more secure
      override_http_method: 'POST' # default: nil
    }
  }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/JanStevens/artemis-api-auth

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
