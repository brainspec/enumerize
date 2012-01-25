# -*- encoding: utf-8 -*-
require File.expand_path('../lib/enumerize/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Sergey Nartimov"]
  gem.email         = ["just.lest@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "enumerize"
  gem.require_paths = ["lib"]
  gem.version       = Enumerize::VERSION

  gem.add_dependency('activesupport', '>= 3.1.3')
end
