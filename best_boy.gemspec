# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "best_boy/version"

Gem::Specification.new do |s|
  s.name        = "best_boy"
  s.version     = BestBoy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.licenses     =["MIT"]
  s.authors     = ["Christoph Seydel, Robin Neumann, Daniel Schoppmann"]
  s.email       = ["christoph.seydel@me.com, daniel.schoppmann@gmail.com"]
  s.homepage    = "https://github.com/absolventa/best_boy"
  s.summary     = %q{a simple event driven logging for models}
  s.description = %q{Hybrid action logging, consisting of standard and custom logging.}

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]

  s.add_dependency 'rails', '>= 4.0.0', '< 5.0'
  s.add_dependency 'kaminari', '>= 0.14.1', '~> 0.16.1'
  s.add_dependency 'google_visualr'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency "rspec-rails", "~> 3.0.2"
  s.add_development_dependency 'shoulda', "~> 3.5"
  s.add_development_dependency "haml"
  s.add_development_dependency 'sass-rails', '~> 4.0.0'
end
