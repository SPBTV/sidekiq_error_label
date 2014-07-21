# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq_error_separator/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq_error_separator"
  spec.version       = SidekiqErrorSeparator::VERSION
  spec.authors       = ["Tema Bolshakov"]
  spec.email         = ["abolshakov@spbtv.com"]
  spec.summary       = %q{Mark frequent exceptions as important.}
  spec.description   = %q{Mark frequent exceptions as important.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sidekiq"
end
