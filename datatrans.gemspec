# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "datatrans/version"

Gem::Specification.new do |s|
  s.name        = "datatrans"
  s.version     = Datatrans::VERSION
  s.authors     = ["Tobias Miesel", "Thomas Maurer", "Corin Langosch", "Pascal Betz"]
  s.email       = ["info@simplificator.com"]
  s.homepage    = ""
  s.summary     = %q{Datatrans Integration for Ruby on Rails}
  s.description = %q{Datatrans Integration for Ruby on Rails}

  s.rubyforge_project = "datatrans"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.6'

  s.add_dependency 'httparty'
  s.add_dependency 'activesupport', '>= 5.2'
  s.add_dependency 'i18n'
  s.add_dependency 'builder'
  s.add_dependency 'multi_xml', '>= 0.5.1'

  s.add_development_dependency 'actionpack', '>= 5.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.license = 'MIT'
end
