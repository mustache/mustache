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
  require 'sdoc'
  Rake::RDocTask.new do |rdoc|
    rdoc.main = 'README.md'
    rdoc.rdoc_files = %w( README.md LICENSE lib )
    rdoc.rdoc_dir = 'docs'
  end
rescue LoadError
  puts "sdoc support not enabled. Please install sdoc."
end

##
# Markdown support for sdoc. Renders files ending in .md or .markdown
# with RDiscount.
module SDoc
  module MarkdownSupport
    def description
      return super unless full_name =~ /\.(md|markdown)$/
      # assuming your path is ROOT/html or ROOT/doc
      path = Dir.pwd + '/../' + full_name
      Markdown.new(File.read(path)).to_html + open_links_in_new_window
    end

    def open_links_in_new_window
      <<-html
<script type="text/javascript">$(function() {
  $('a').each(function() { $(this).attr('target', '_blank') })
})</script>
html
    end
  end
end

begin
  require 'rdiscount'
  RDoc::TopLevel.send :include, SDoc::MarkdownSupport
rescue LoadError
  puts "Markdown support not enabled. Please install RDiscount."
end
