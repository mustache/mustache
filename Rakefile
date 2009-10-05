require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc "Build sdoc documentation"
task :doc do
  File.open('README.html', 'w') do |f|
    require 'rdiscount'
    f.puts Markdown.new(File.read('README.md')).to_html
  end

  exec "sdoc -N --main=README.html README.html LICENSE lib"
end
