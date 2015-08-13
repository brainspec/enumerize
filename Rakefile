#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'
require 'rspec/core/rake_task'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

RSpec::Core::RakeTask.new

task :default => [:test, :spec]
