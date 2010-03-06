require 'rake/testtask'
require 'rake/rdoctask'

task :default => :test

desc "Build a gem."
task :gem => [ :gemspec, :build ]

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc "Build the manual"
task :build_man do
  sh "ron -br5 --organization=DEFUNKT --manual='Mustache Manual' man/*.ron"
end

desc "Show the manual"
task :man => :build_man do
  exec "man man/mustache.1"
end

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
    gemspec.summary =
      "Mustache is a framework-agnostic way to render logic-free views."
    gemspec.version = Mustache::Version
    gemspec.executables = ["mustache"]
    gemspec.homepage = "http://github.com/defunkt/mustache"
    gemspec.authors = ["Chris Wanstrath"]
    gemspec.email = "chris@ozmm.org"
    gemspec.description = <<description
Inspired by ctemplate, Mustache is a framework-agnostic way to render
logic-free views.

As ctemplates says, "It emphasizes separating logic from presentation:
it is impossible to embed application logic in this template
language.

Think of Mustache as a replacement for your views. Instead of views
consisting of ERB or HAML with random helpers and arbitrary logic,
your views are broken into two parts: a Ruby class and an HTML
template.
description
  end

rescue LoadError
  warn "Jewler not available."
  warn "Install it with: gem i jewler"
end

# begin
#   require 'sdoc_helpers'
# rescue LoadError
#   warn "sdoc support not enabled. Please gem install sdoc-helpers."
# end

desc "Push a new version to Gemcutter"
task :publish => [ :test, :gemspec, :build ] do
  system "git tag v#{Mustache::Version}"
  system "git push origin v#{Mustache::Version}"
  system "git push origin master"
  system "gem push pkg/mustache-#{Mustache::Version}.gem"
  system "git clean -fd"
  exec "rake pages"
end

desc "Publish to GitHub Pages"
task :pages => [ :build_man, :check_dirty ] do
  Dir['man/*.html'].each do |f|
    cp f, File.basename(f).sub('.html', '.newhtml')
  end

  `git checkout gh-pages`

  Dir['*.newhtml'].each do |f|
    mv f, f.sub('.newhtml', '.html')
  end

  `git add .`
  `git commit -m updated`
  `git push origin gh-pages`
  `git checkout master`
  puts :done
end

task :check_dirty do
  if !`git status`.include?('nothing to commit')
    abort "dirty index - not publishing!"
  end
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
