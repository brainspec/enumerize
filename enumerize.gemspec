# -*- encoding: utf-8 -*-
require File.expand_path('../lib/enumerize/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Sergey Nartimov"]
  gem.email         = "team@brainspec.com"
  gem.licenses      = ['MIT']
  gem.description   = %q{Enumerated attributes with I18n and ActiveRecord/Mongoid/MongoMapper support}
  gem.summary       = %q{Enumerated attributes with I18n and ActiveRecord/Mongoid/MongoMapper support}
  gem.homepage      = "https://github.com/brainspec/enumerize"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "enumerize"
  gem.require_paths = ["lib"]
  gem.version       = Enumerize::VERSION

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency('activesupport', '>= 3.2')
end
