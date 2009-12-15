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
