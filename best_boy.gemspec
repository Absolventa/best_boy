$:.push File.expand_path("../lib", __FILE__)
require "best_boy/version"

Gem::Specification.new do |s|
  s.name        = "best_boy"
  s.version     = BestBoy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.licenses     =["MIT"]
  s.authors     = ["Christoph Seydel, Carsten Zimmermann, Robin Neumann, Daniel Schoppmann"]
  s.email       = ["christoph.seydel@me.com, daniel.schoppmann@gmail.com"]
  s.homepage    = "https://github.com/absolventa/best_boy"
  s.summary     = %q{a simple event driven logging for models}
  s.description = %q{Hybrid action logging, consisting of standard and custom logging.}

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]

  s.add_dependency 'rails', '>= 4.2.0', '< 5.1'
  s.add_dependency 'kaminari', '>= 0.14.1'
  s.add_dependency 'google_visualr'
  s.add_dependency 'haml'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency "rspec-rails", "~> 3.5.0.beta1"
  s.add_development_dependency 'shoulda', ">= 3.5"
  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'sass-rails'
end
