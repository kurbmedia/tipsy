#!/usr/bin/env rake
$:.unshift File.expand_path('.', __FILE__)

require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/**/*_test.rb']
  t.libs << 'lib'
  t.libs << 'test'    
  t.verbose = true
end