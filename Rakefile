require 'rake/testtask'
require 'rake/rdoctask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

begin
  require 'jeweler'
  $LOAD_PATH.unshift 'lib'
  require 'mustache/version'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "mustache"
    gemspec.summary = "Mustache is a framework-agnostic way to render logic-free views."
    gemspec.description = "Mustache is a framework-agnostic way to render logic-free views."
    gemspec.email = "chris@ozmm.org"
    gemspec.homepage = "http://github.com/defunkt/mustache"
    gemspec.authors = ["Chris Wanstrath"]
    gemspec.version = Mustache::Version
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

begin
  require 'sdoc_helpers'
rescue LoadError
  puts "sdoc support not enabled. Please gem install sdoc-helpers."
end
