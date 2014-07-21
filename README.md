# SidekiqErrorSeparator

Mark frequent exceptions as important.

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq_error_separator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq_error_separator

## Usage

Include middleware to server chain and configure list of errors which should be marked as `ImportantError`. 

```ruby
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SidekiqErrorSeparator::Middleware, exceptions: [
      Errno::ECONNRESET,
      Net::OpenTimeout,
      Errno::EHOSTUNREACH,
      Net::ReadTimeout
    ], retries_threshold: 3
  end
end
```

## Contributing

1. Fork it ( https://github.com/SPBTV/sidekiq_error_separator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
