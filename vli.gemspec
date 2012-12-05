# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vli/version'

Gem::Specification.new do |gem|
  gem.name          = "vli"
  gem.version       = Vli::VERSION
  gem.authors       = ["Tyler Flint"]
  gem.email         = ["tylerflint@gmail.com"]
  gem.description   = %q{Vagrant Like Interface is a library of components extracted from the vagrant project to aid in building command line interfaces.}
  gem.summary       = %q{library of components extracted from the vagrant project}
  gem.homepage      = "http://github.com/tylerflint/vli"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
