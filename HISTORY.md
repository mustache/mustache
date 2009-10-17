## 0.3.1 (2009-??-??)

* Added mustache.vim to contrib/ (Thanks Juvenn Woo!)
* Support string keys in contexts (not just symbol keys).

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
