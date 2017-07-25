# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pocketsphinx/version'

Gem::Specification.new do |spec|
  spec.name          = "pocketsphinx-ruby"
  spec.version       = Pocketsphinx::VERSION
  spec.authors       = ["Howard Wilson"]
  spec.email         = ["howard@watsonbox.net"]
  spec.summary       = %q{Ruby speech recognition with Pocketsphinx}
  spec.description   = %q{Provides Ruby FFI bindings for Pocketsphinx, a lightweight speech recognition engine.}
  spec.homepage      = "https://github.com/watsonbox/pocketsphinx-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi", ">= 1.9"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "byebug"
end
