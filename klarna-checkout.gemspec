# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'klarna/checkout/version'

Gem::Specification.new do |spec|
  spec.name          = "klarna-checkout"
  spec.version       = Klarna::Checkout::VERSION
  spec.authors       = ["Theodor Tonum"]
  spec.email         = ["theodor@tonum.no"]
  spec.description   = %q{Ruby Wrapper for Klarna Checkout Rest API}
  spec.summary       = %q{...}
  spec.homepage      = "https://github.com/rorkjop/klarna-checkout-ruby"
  spec.license       = "MIT"

  spec.files         = Dir['LICENSE.txt', 'README.md', 'lib/**/*']
  spec.test_files    = Dir['spec/**/*']
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"
  spec.add_dependency "activesupport"
  spec.add_dependency "activemodel"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
end
