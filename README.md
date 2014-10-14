# SidekiqErrorLabel

Label sidekiq exception.

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq_error_label'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq_error_label

## Usage

Include middleware to server chain and configure list of errors which should be marked as `SilentException`. 

```ruby
module SilentException
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SidekiqErrorLabel::Middleware, 
        exceptions: [
          Errno::ECONNRESET,
          Net::OpenTimeout,
          Errno::EHOSTUNREACH,
          Net::ReadTimeout
        ], 
        retries_threshold: 3,
        as: SilentException
  end
end
```


Middleware extands listed exceptions with `SilentException` module if same job
have been failing with one of this errors for `retries_threshold` times. So you may catch them by the module name.

If no `:as` option given exceptions would be labeled with `SidekiqErrorLabel::Middleware::Labels::Default`

E.g. you may configure Airbrake to log those types of errors only if job have failed `retries_threshold` times in a row:

```ruby
Airbrake.configure do |config|
  config.ignore_by_filter do |exception_data|
    exception = exception_data[:exception]
    exception.present? && exception.kind_of?(SilentException)
  end
end
```

You may create labels on the fly:

```ruby
SidekiqErrorLabel::Middleware.label(:default) #=> SidekiqErrorLabel::Middleware::Labels::Default
SidekiqErrorLabel::Middleware.label(:Silent) #=> SidekiqErrorLabel::Middleware::Labels::Silent
```

## Contributing

1. Fork it ( https://github.com/SPBTV/sidekiq_error_label/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Copyright 2014 SPB TV AG

Licensed under the Apache License, Version 2.0 (the ["License"](LICENSE)); you may not use this file except in compliance with the License.

You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 

See the License for the specific language governing permissions and limitations under the License.

