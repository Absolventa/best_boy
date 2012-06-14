# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "best_boy/version"

Gem::Specification.new do |s|
  s.name        = "best_boy"
  s.version     = BestBoy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = ['MIT']
  s.authors     = ["Christoph Seydel"]
  s.email       = ["christoph.seydel@me.com"]
  s.homepage    = "https://github.com/cseydel/best_boy"
  s.summary     = %q{a simple event driven logging for models}
  s.description = %q{Hybrid action logging, consisting of standard and custom logging.}

  s.rubyforge_project = "best_boy"
  s.required_rubygems_version = ">= 1.3.6"

  #s.add_dependency()

  s.add_development_dependency("bundler")
  s.add_development_dependency('activerecord')
  s.add_development_dependency('activesupport')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency("rake")  
  s.add_development_dependency("rspec")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
