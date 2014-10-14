# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pocketsphinx/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-pocketsphinx"
  spec.version       = Pocketsphinx::VERSION
  spec.authors       = ["Howard Wilson"]
  spec.email         = ["howard@watsonbox.net"]
  spec.summary       = %q{Ruby pocketsphinx bindings}
  spec.description   = %q{Ruby pocketsphinx bindings generated using SWIG interface.}
  spec.homepage      = "https://github.com/watsonbox/ruby-pocketsphinx"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
