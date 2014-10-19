require "bundler/gem_tasks"
require 'rake/clean'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => [:spec]
rescue LoadError
end
