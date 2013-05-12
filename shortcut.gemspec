# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shortcut/version'

Gem::Specification.new do |spec|
  spec.name          = "shortcut"
  spec.version       = Shortcut::VERSION
  spec.authors       = ["Décio Ferreira"]
  spec.email         = ["decioferreira@decioferreira.com"]
  spec.description   = %q{Make your own Bot}
  spec.summary       = %q{Make your own Bot}
  spec.homepage      = "https://github.com/decioferreira/shortcut"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "warbler"
  spec.add_development_dependency "guard-rspec"
end
