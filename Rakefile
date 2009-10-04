require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc "Build sdoc documentation"
task :doc do
  exec "sdoc --main=README.md README.md LICENSE lib"
end
