# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-nis/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ryan Campbell"]
  gem.email         = ["campbellr@gmail.com"]
  gem.description   = %q{A NIS strategy for OmniAuth.}
  gem.summary       = %q{A NIS strategy for OmniAuth.}
  gem.homepage      = "https://github.com/campbellr/omniauth-nis"
  gem.license       = "MIT"

  gem.add_runtime_dependency     'omniauth', '~> 1.0'
  gem.add_runtime_dependency     'unix-crypt', '~> 1.3.0'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'libnotify'
  gem.add_development_dependency 'ruby-debug19'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth-nis"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::NIS::VERSION
end
