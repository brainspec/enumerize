#!/usr/bin/env rake
# frozen_string_literal: true

require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

if ENV['TEST_FRAMEWORK'] == 'rspec'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new

  task :default => [:spec]
else
  task :default => [:test]
end
