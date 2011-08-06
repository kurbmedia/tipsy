# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tipsy/version"

Gem::Specification.new do |s|
  
  s.name        = "tipsy"
  s.version     = Tipsy::VERSION
  s.authors     = ["Brent Kirby"]
  s.email       = ["brent@kurbmedia.com"]
  s.homepage    = ""
  s.summary     = %q{A mini Rack application server for developing static sites.}
  s.description = %q{Tipsy is a mini Rack application for working with static websites using Tilt, Compass, and Sprockets.}

  s.rubyforge_project = "tipsy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("rack", "~> 1.2")
  s.add_dependency("rack-test", "~> 0.5")
  s.add_dependency("tilt", "~> 1.3")
  s.add_dependency("i18n", "~> 0.5")
  s.add_dependency("sass", "~> 3.1")
  s.add_dependency("active_support", ">= 3.0")
  s.add_dependency('sprockets', '~> 2.0.0.beta.12')
  
end
