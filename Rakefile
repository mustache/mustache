require 'rake/testtask'

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

desc "Build sdoc documentation"
task :doc do
  File.open('README.html', 'w') do |f|
    require 'rdiscount'
    f.puts Markdown.new(File.read('README.md')).to_html
  end

  exec "sdoc -N --main=README.html README.html LICENSE lib"
end
