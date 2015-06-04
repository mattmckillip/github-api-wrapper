# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'turnt/octo/archer/version'

Gem::Specification.new do |spec|
  spec.name          = "turnt-octo-archer"
  spec.version       = Turnt::Octo::Archer::VERSION
  spec.authors       = ["Matt McKillip"]
  spec.email         = ["matt.mckillip@cerner.com"]
  spec.summary       = "This gem is a wrapper around the GitHub API. I am using this as a learning tool for Ruby."
  spec.description   = "Use this to get information from a specified repo."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = "turnt-octo-archer"
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "nyan-cat-formatter"

end