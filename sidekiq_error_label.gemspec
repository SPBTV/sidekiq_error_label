# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq_error_label/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq_error_label"
  spec.version       = SidekiqErrorLabel::VERSION
  spec.authors       = ["Tema Bolshakov"]
  spec.email         = ["abolshakov@spbtv.com"]
  spec.summary       = %q{Label sidekiq exception.}
  spec.description   = %q{Label sidekiq exception.}
  spec.homepage      = "https://github.com/SPBTV/sidekiq_error_label"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sidekiq"
  spec.add_runtime_dependency 'activesupport'
end
