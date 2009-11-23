require 'rake/testtask'
require 'rake/rdoctask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc "Build a gem"
task :gem => [ :gemspec, :build ]

desc "Launch Kicker (like autotest)"
task :kicker do
  puts "Kicking... (ctrl+c to cancel)"
  exec "kicker -e rake test lib examples"
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
  puts "Jeweler not available."
  puts "Install it with: gem install jeweler"
end

begin
  require 'sdoc_helpers'
rescue LoadError
  puts "sdoc support not enabled. Please gem install sdoc-helpers."
end

desc "Push a new version to Gemcutter"
task :publish => [ :test, :gemspec, :build ] do
  system "git tag v#{Mustache::Version}"
  system "git push origin v#{Mustache::Version}"
  system "git push origin master"
  system "gem push pkg/mustache-#{Mustache::Version}.gem"
  system "git clean -fd"
  exec "rake pages"
end

desc "Install the edge gem"
task :install_edge => [ :dev_version, :gemspec, :build ] do
  exec "gem install pkg/mustache-#{Mustache::Version}.gem"
end

# Sets the current Mustache version to the current dev version
task :dev_version do
  $LOAD_PATH.unshift 'lib/mustache'
  require 'mustache/version'
  version = Mustache::Version + '.' + Time.now.to_i.to_s
  Mustache.const_set(:Version, version)
end
