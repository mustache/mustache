## 1.0.2 (2015-06-24)

* Adds benchmarks (#197)
* Clarify documentation around content without HTML escaping (#203)
* Fix some Ruby warnings (#204)
* Improve performance when using partials inside loops (#205)

## 1.0.1 (2015-02-23)

* Always cast to hash on hash-like object lookups (#187)
* Fixed -v option in the binary (#189)
* Missing partial returns "" per the spec (#200)

# 1.0.0 (2015-01-11)

* Bugfixes
* Now requires Ruby >= 2.0
* Removed mustache_sinatra to separate gem
* Removed rack-bug-mustache_panel to separate gem

## 0.99.6 (2014-07-22)

* Fixed and updated documentation
* Added license to gemspec
* Allows Hash default proc to work in context
* Avoids raising ContextMiss when testing for key presence
* Refactored Parser to allow for better extensibility
* 1.9.3+ YAML compatibility
* Support allowed liberal tag names in classes
* Removed redundant Parser#scan_tag> code
* Mustache command works with pure json files
* Enumerate any object tagged with Mustache::Enumerable
* Rescue NameError when Views module isn't found
* Adds Gemfile

## 0.99.5 (2013-11-11)

* Added line offsets to parser ast
* Sinatra: `mustache` takes a View class to skip lookups
* Fixed warning for shadowing outer local variable
* Fixed typos

## 0.99.4 (2011-05-26)

* Reverted automatically attr_accessors in Sinatra. Too much magic.

## 0.99.3 (2011-03-06)

* Fixed method_missing support
* Fixed whitespace errors

## 0.99.2 (2011-03-06)

* Added some HTML5 tags to tpl-mode.el
* Bugfix: {{#sections}} and whitespace

## 0.99.1 (2011-03-01)

* Bugfix: Strings used in sections no longer enumerate.

## 0.99.0 (2011-02-28)

* Unary methods of Mustache view can now be used in sections as procs.
* Added instance-level versions of all view settings.
* Emacs mode: Support for dot notation
* Sinatra: Support for `mustache "views/in/sub/directories"`

## 0.98.0 (2011-02-24)

* Dot Notation: {{person.name}}
* Implicit Iterators: {{# people}} {{.}} {{/ people}}
* Automagic attr_readers for ivars you set in Sinatra routes.
* Ability to customize escaping by overriding Mustache#escapeHTML

## 0.13.0 (2011-02-23)

* Mustache.render accepts a symbol to specify a template name.
* Bugfix: Struct can be used as sections again

## 0.12.1 (2011-02-22)

* Bugfixes!

## 0.12.0 (2010-12-10)

* Passing the full draft Mustache spec.
* Instance render: `@view.render(:thing => :world)`
* Sinatra bugfix: 'layout not found' fix

## 0.11.2 (2010-05-13)

* Sinatra bugfix: `mustache :"TEMPLATE.atom"`

## 0.11.1 (2010-05-12)

* mustache(1) bugfix: Render even without data.

## 0.11.0 (2010-04-18)

* Higher Order Sections. See mustache(5) for details.
* Add inheritable class ivars on Mustache for @options.

## 0.10.0 (2010-04-02)

* Added Inverted Sections (^). See mustache(5) for details.
* Added Template#source for accessing the template's string source.
* Bugfix: 1.9 encoding fix
* Sinatra Bugfix: 1.9 compat

## 0.9.2 (2010-03-29)

* Sinatra: Bugfix for `mustache :view, :layout => true`
* Mustache class now implements `partial` so you can call `super`
  when providing a custom `partial` method.
* Bugfix: Allow slashes in tags, especially partials.

## 0.9.1 (2010-03-27)

* Bugfix: Partials use the nearest context when being rendered.
* Bugfix: Partials returned by the partial method are now rendered.

## 0.9.0 (2010-03-26)

* New, cleaner parser by Magnus Holm!
* Improved error messages!
* Bugfixes!
* Faster runtime!
* Sinatra 1.0 compatibility with layout tag overriding!

## 0.7.0 (2010-03-25)

* `Mustache.compile` for compiling a template into Ruby.
* `mustache -c FILE` to see a template's compiled Ruby.
* Recursive partial support.
* Added `&` as an alias for the triple mustache (unescaped HTML).
* Simpler examples. Old examples are now test fixtures.

## 0.6.0 (2010-03-08)

* Ruby objects can be used in sections, not just hashes. See
  http://github.com/defunkt/mustache/commit/9477619638
* As a result, `TypeError` is no longer thrown when hashes are not
  passed.
* mustache(1) man page is now included
* mustache(5) man page is now included
* tpl-mode.el has been renamed mustache-mode.el
* Improved README

## 0.5.1 (2009-12-15)

* Added "mail merge" functionality to `mustache` script.
* Support for multi-line tags (useful for comments)
* Sinatra Bugfix: Use Sinatra app's view path, not Sinatra base class'.

## 0.5.0 (2009-11-23)

* Partial classes are no longer supported. Use modules!
* Added `mustache` script for rendering templates on the command line.
* ctemplate compat: Partials are indicated by >, not <
* Bugfix: Context miss should return nil, not empty string. Fixes 1.9.x

## 0.4.2 (2009-10-28)

* Bugfix: Ignore bad constant names when autoloading

## 0.4.1 (2009-10-27)

* Partials now respect the `view_namespace` setting.
* Added tpl-mode.el to contrib/ for us Emacs users.
* Rack::Bug bugfix: ensure benchmark is required before using it
* Rack::Bug: truncate too-large variables (click expands them)

## 0.4.0 (2009-10-27)

* Stopped raising context miss exceptions by default
* Added `Mustache.raise_on_context_miss` setting (defaults to false)
* Throw Mustache::ContextMiss when raise_on_context_miss is true and
  we encounter a miss.
* The default template extension is now "mustache" (instead of "html").
* Added the `view_namespace` and `view_path` settings to `Mustache`
* Added `Mustache.view_class` method which autoloads a class using the
  new `view_namespace` and `view_path` settings. Should be used by
  plugin developers.
* Updated the Sinatra extension to use the new `view_class` method
* Unclosed sections now throw a helpful error message
* Report line numbers on unclosed section errors
* Added Rack::Bug panel

## 0.3.2 (2009-10-19)

* Bugfix: Partials in Sinatra were using the wrong path.

## 0.3.1 (2009-10-19)

* Added mustache.vim to contrib/ (Thanks Juvenn Woo!)
* Support string keys in contexts (not just symbol keys).
* Bugfix: # and / were not permitted in tag names. Now they are.
* Bugfix: Partials in Sinatra needed to know their extension and path
* Bugfix: Using the same boolean section twice was failing

## 0.3.0 (2009-10-14)

* Set Delimiter tags are now supported. See the README
* Improved error message when an enumerable section did not return all
  hashes.
* Added a shortcut: if a section's value is a single hash, treat is as
  a one element array whose value is the hash.
* Bugfix: String templates set at the class level were not compiled
* Added a class-level `compiled?` method for checking if a template
  has been compiled.
* Added an instance-level `compiled?` method.
* Cache template compilation in Sinatra

## 0.2.2 (2009-10-11)

* Improved documentation
* Fixed single line sections
* Broke preserved indentation (issue #2)

## 0.2.1 (2009-10-11)

* Mustache.underscore can now be called without an argument
* Settings now mostly live at the class level, excepting `template`
* Any setting changes causes the template to be recompiled
