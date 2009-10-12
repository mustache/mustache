## 0.2.3 (2009-??-??)

* Improved error message when an enumerable section did not return all
  hashes.
* Added a shortcut: if a section's value is a single hash, treat is as
  a one element array whose value is the hash.

## 0.2.2 (2009-10-11)

* Improved documentation
* Fixed single line sections
* Broke preserved indentation (issue #2)

## 0.2.1 (2009-10-11)

* Mustache.underscore can now be called without an argument
* Settings now mostly live at the class level, excepting `template`
* Any setting changes causes the template to be recompiled
