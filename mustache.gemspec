$LOAD_PATH.unshift 'lib'
require 'mustache/version'

Gem::Specification.new do |s|
  s.name              = "mustache"
  s.version           = Mustache::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           =
        "Mustache is a framework-agnostic way to render logic-free views."
  s.homepage          = "https://github.com/mustache/mustache"
  s.email             = "rokusu@gmail.com"
  s.authors           = [ "Chris Wanstrath", "Magnus Holm", "Pieter van de Bruggen", "Ricardo Mendes" ]
  s.license           = "MIT"
  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("man/**/*")
  s.files            += Dir.glob("test/**/*")
  s.executables       = %w( mustache )
  s.description       = <<desc
Inspired by ctemplate, Mustache is a framework-agnostic way to render
logic-free views.

As ctemplates says, "It emphasizes separating logic from presentation:
it is impossible to embed application logic in this template
language.

Think of Mustache as a replacement for your views. Instead of views
consisting of ERB or HAML with random helpers and arbitrary logic,
your views are broken into two parts: a Ruby class and an HTML
template.
desc

  s.required_ruby_version = '>= 2.0'
end
