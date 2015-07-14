# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unsplash/version'

Gem::Specification.new do |spec|
  spec.name          = "unsplash"
  spec.version       = Unsplash::VERSION
  spec.authors       = ["Aaron Klaassen"]
  spec.email         = ["aaron@crew.co"]

  spec.summary       = %q{Ruby wrapper for the Unsplash API.}
  spec.homepage      = "https://github.com/CrewLabs/unsplash_rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "httparty", "~> 0.13.5"
  spec.add_dependency "oauth2",   "~> 1.0.0"

  # spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "rspec",   "~> 3.3.0"
  spec.add_development_dependency "vcr",     "~> 2.9.3"
  spec.add_development_dependency "webmock", "~> 1.20.4"
  spec.add_development_dependency "pry"
end
