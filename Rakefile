require 'rake/testtask'
require 'rake/rdoctask'

def command?(command)
  system("type #{command} > /dev/null")
end

#
# Tests
#

task :default => :test

if command? :turn
  desc "Run tests"
  task :test do
    suffix = "-n #{ENV['TEST']}" if ENV['TEST']
    sh "turn test/*.rb #{suffix}"
  end
else
  Rake::TestTask.new do |t|
    t.libs << 'lib'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = false
  end
end

#
# Ron
#

if command? :ron
  desc "Show the manual"
  task :man => "man:build" do
    exec "man man/mustache.1"
  end

  desc "Build the manual"
  task "man:build" do
    sh "ron -br5 --organization=DEFUNKT --manual='Mustache Manual' man/*.ron"
  end
end

if command? :kicker
  desc "Launch Kicker (like autotest)"
  task :kicker do
    puts "Kicking... (ctrl+c to cancel)"
    exec "kicker -e rake test lib examples"
  end
end

#
# Gems
#

begin
  require 'mg'
  MG.new("mustache.gemspec")

  desc "Build a gem."
  task :gem => :package

  # Ensure tests pass before pushing a gem.
  task :gemcutter => :test

  desc "Push a new version to Gemcutter and publish docs."
  task :publish => :gemcutter do
    require File.dirname(__FILE__) + '/lib/mustache/version'

    system "git tag v#{Mustache::Version}"
    sh "git push origin master --tags"
    sh "git clean -fd"
    exec "rake pages"
  end
rescue LoadError
  warn "mg not available."
  warn "Install it with: gem i mg"
end

#
# Documentation
#

# begin
#   require 'sdoc_helpers'
# rescue LoadError
#   warn "sdoc support not enabled. Please gem install sdoc-helpers."
# end

desc "Publish to GitHub Pages"
task :pages => [ "man:build" ] do
  Dir['man/*.html'].each do |f|
    cp f, File.basename(f).sub('.html', '.newhtml')
  end

  `git commit -am 'generated manual'`
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
