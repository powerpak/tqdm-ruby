# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tqdm/version'

Gem::Specification.new do |spec|
  spec.name          = "tqdm"
  spec.version       = Tqdm::VERSION
  spec.authors       = ["Theodore Pak"]
  spec.email         = ["theodore.r.pak@gmail.com"]
  spec.description   = %q{Enhances Enumerables to show progress while iterating. (Port of tqdm for Python.)}
  spec.summary       = %q{Enhances Enumerables to show progress while iterating.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
