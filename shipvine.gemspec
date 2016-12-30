# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shipvine/version'

Gem::Specification.new do |spec|
  spec.name          = "shipvine"
  spec.version       = Shipvine::VERSION
  spec.authors       = ["Michael Bianco"]
  spec.email         = ["mike@cliffsidemedia.com"]

  spec.summary       = %q{Shipvine API bindings}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/iloveitaly/shipvine-ruby"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty', '~> 0.13.7'
  spec.add_dependency 'gyoku', '~> 1.3.1'
  spec.add_dependency 'nori', '~> 2.6.0'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
