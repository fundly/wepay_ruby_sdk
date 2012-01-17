# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wepay_ruby_sdk/version"

Gem::Specification.new do |s|
  s.name        = "wepay_ruby_sdk"
  s.version     = WepayRubySdk::VERSION
  s.authors     = ["Bernd Ustorf"]
  s.email       = ["bernd.ustorf@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{gemified version of wepay's SDK}
  s.description = %q{gemified version of wepay's SDK}

  s.rubyforge_project = "wepay_ruby_sdk"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
