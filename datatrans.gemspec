# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "datatrans/version"

Gem::Specification.new do |s|
  s.name        = "datatrans"
  s.version     = Datatrans::VERSION
  s.authors     = ["Tobias Miesel", "Thomas Maurer", "Corin Langosch"]
  s.email       = ["tobias.miesel@simplificator.com", "thomas.maurer@simplificator.com", "corin.langosch@simplificator.com"]
  s.homepage    = ""
  s.summary     = %q{Datatrans Integration for Ruby on Rails}
  s.description = %q{Datatrans Integration for Ruby on Rails}

  s.rubyforge_project = "datatrans"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'httparty'
  s.add_dependency 'activesupport', '>= 3.0.0'
  s.add_dependency 'i18n'
  s.add_dependency 'builder'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'actionpack', '>= 3.0.0'
end
