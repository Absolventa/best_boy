require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new(:spec)
task :default => :spec
