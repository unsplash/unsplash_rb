# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unsplash/version'

Gem::Specification.new do |spec|
  spec.name          = "unsplash"
  spec.version       = Unsplash::VERSION
  spec.authors       = ["Aaron Klaassen"]
  spec.email         = ["aaron@unsplash.com"]

  spec.summary       = %q{Ruby wrapper for the Unsplash API.}
  spec.homepage      = "https://github.com/unsplash/unsplash_rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_dependency "httparty", "~> 0.16.4"
  spec.add_dependency "oauth2",   "~> 1"

  # spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake",    "~> 12.0"
  spec.add_development_dependency "rspec",   "~> 3.5.0"
  spec.add_development_dependency "vcr",     "~> 3.0.0"
  spec.add_development_dependency "webmock", "~> 2.3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "coveralls", '~> 0.8.17'
end
