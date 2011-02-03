# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "translatable_attributes/version"

Gem::Specification.new do |s|
  s.name        = "translatable_attributes"
  s.version     = TranslatableAttributes::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["JJ Buckley"]
  s.email       = ["translatable_attributes@bjjb.org"]
  s.homepage    = "http://jjbuckley.github.com/translatable_attributes"
  s.summary     = %q{Automagic attribute translations for ActiveRecord}
  s.description = %q{A Ruby module which fakes out internationalised attributes on the fly.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'i18n-active_record', '>= 0.0.2'
end
