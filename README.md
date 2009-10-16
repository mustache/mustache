Mustache
=========

Inspired by [ctemplate][1] and [et][2], Mustache is a
framework-agnostic way to render logic-free views.

As ctemplates says, "It emphasizes separating logic from presentation:
it is impossible to embed application logic in this template language."


Overview
--------

Think of Mustache as a replacement for your views. Instead of views
consisting of ERB or HAML with random helpers and arbitrary logic,
your views are broken into two parts: a Ruby class and an HTML
template.

We call the Ruby class the "view" and the HTML template the
"template."

All your logic, decisions, and code is contained in your view. All
your markup is contained in your template. The template does nothing
but reference methods in your view.

This strict separation makes it easier to write clean templates,
easier to test your views, and more fun to work on your app's front end.


Why?
----

I like writing Ruby. I like writing HTML. I like writing JavaScript.

I don't like writing ERB, Haml, Liquid, Django Templates, putting Ruby
in my HTML, or putting JavaScript in my HTML.


Usage
-----

Quick example:

    >> require 'mustache'
    => true
    >> Mustache.render("Hello {{planet}}", :planet => "World!")
    => "Hello World!"

We've got an `examples` folder but here's the canonical one:

    class Simple < Mustache
      def name
        "Chris"
      end

      def value
        10_000
      end

      def taxed_value
        value - (value * 0.4)
      end

      def in_ca
        true
      end
    end

We simply create a normal Ruby class and define methods. Some methods
reference others, some return values, some return only booleans.

Now let's write the template:

    Hello {{name}}
    You have just won ${{value}}!
    {{#in_ca}}
    Well, ${{taxed_value}}, after taxes.
    {{/in_ca}}

This template references our view methods. To bring it all together,
here's the code to render actual HTML;

    Simple.render

Which returns the following:

    Hello Chris
    You have just won $10000!
    Well, $6000.0, after taxes.

Simple.


Tag Types
---------

Tags are indicated by the double mustaches. `{{name}}` is a tag. Let's
talk about the different types of tags.

### Variables

The most basic tag is the variable. A `{{name}}` tag in a basic
template will try to call the `name` method on your view. If there is
no `name` method, an exception will be raised.

All variables are HTML escaped by default. If you want, for some
reason, to return unescaped HTML you can use the triple mustache:
`{{{name}}}`.

### Boolean Sections

A section begins with a pound and ends with a slash. That is,
`{{#person}}` begins a "person" section while `{{/person}}` ends it.

If the `person` method exists and calling it returns false, the HTML
between the pound and slash will not be displayed.

If the `person` method exists and calling it returns true, the HTML
between the pound and slash will be rendered and displayed.

### Enumerable Sections

Enumerable sections are syntactically identical to boolean sections in
that they begin with a pound and end with a slash. The difference,
however, is in the view: if the method called returns an enumerable,
the section is repeated as the enumerable is iterated over.

Each item in the enumerable is expected to be a hash which will then
become the context of the corresponding iteration. In this way we can
construct loops.

For example, imagine this template:

    {{#repo}}
      <b>{{name}}</b>
    {{/repo}}

And this view code:

    def repo
      Repository.all.map { |r| { :name => r.to_s } }
    end

When rendered, our view will contain a list of all repository names in
the database.

As a convenience, if a section returns a hash (as opposed to an array
or a boolean) it will be treated as a single item array.

With the above template, we could use this Ruby code for a single
iteration:

    def repo
      { :name => Repository.first.to_s }
    end

This would be treated by Mustache as functionally equivalent to the
following:

    def repo
      [ { :name => Repository.first.to_s } ]
    end


### Comments

Comments begin with a bang and are ignored. The following template:

    <h1>Today{{! ignore me }}.</h1>

Will render as follows:

    <h1>Today.</h1>

### Partials

Partials begin with a less than sign, like `{{< box}}`.

If a partial's view is loaded, we use that to render the HTML. If
nothing is loaded we render the template directly using our current context.

In this way partials can reference variables or sections the calling
view defines.


### Set Delimiter

Set Delimiter tags start with an equal sign and change the tag
delimiters from {{ and }} to custom strings.

Consider the following contrived example:

    * {{ default_tags }}
    {{=<% %>=}}
    * <% erb_style_tags %>
    <%={{ }}=%>
    * {{ default_tags_again }}

Here we have a list with three items. The first item uses the default
tag style, the second uses erb style as defined by the Set Delimiter
tag, and the third returns to the default style after yet another Set
Delimiter declaration.

According to [ctemplates][3], this "is useful for languages like TeX, where
double-braces may occur in the text and are awkward to use for
markup."

Custom delimiters may not contain whitespace or the equals sign.


Dict-Style Views
----------------

ctemplate and friends want you to hand a dictionary to the template
processor. Mustache supports a similar concept. Feel free to mix the
class-based and this more procedural style at your leisure.

Given this template (winner.html):

    Hello {{name}}
    You have just won ${{value}}!

We can fill in the values at will:

    view = Winner.new
    view[:name] = 'George'
    view[:value] = 100
    view.render

Which returns:

    Hello George
    You have just won $100!

We can re-use the same object, too:

    view[:name] = 'Tony'
    view.render
    Hello Tony
    You have just won $100!


Templates
---------

A word on templates. By default, a view will try to find its template
on disk by searching for an HTML file in the current directory that
follows the classic Ruby naming convention.

    TemplatePartial => ./template_partial.html

You can set the search path using `Mustache.template_path`. It can be set on a
class by class basis:

    class Simple < Mustache
      self.template_path = File.dirname(__FILE__)
      ... etc ...
    end

Now `Simple` will look for `simple.html` in the directory it resides
in, no matter the cwd.

If you want to just change what template is used you can set
`Mustache.template_file` directly:

    Simple.template_file = './blah.html'

Mustache also allows you to define the extension it'll use.

    Simple.template_extension = 'xml'

Given all other defaults, the above line will cause Mustache to look
for './blah.xml'

Feel free to set the template directly:

    Simple.template = 'Hi {{person}}!'

Or set a different template for a single instance:

    Simple.new.template = 'Hi {{person}}!'

Whatever works.


Helpers
-------

What about global helpers? Maybe you have a nifty `gravatar` function
you want to use in all your views? No problem.

This is just Ruby, after all.

    module ViewHelpers
      def gravatar(email, size = 30)
        gravatar_id = Digest::MD5.hexdigest(email.to_s.strip.downcase)
        gravatar_for_id(gravatar_id, size)
      end

      def gravatar_for_id(gid, size = 30)
        "#{gravatar_host}/avatar/#{gid}?s=#{size}"
      end

      def gravatar_host
        @ssl ? 'https://secure.gravatar.com' : 'http://www.gravatar.com'
      end
    end

Then just include it:

    class Simple < Mustache
      include ViewHelpers

      def name
        "Chris"
      end

      def value
        10_000
      end

      def taxed_value
        value - (value * 0.4)
      end

      def in_ca
        true
      end
    end

Great, but what about that `@ssl` ivar in `gravatar_host`? There are
many ways we can go about setting it.

Here's on example which illustrates a key feature of Mustache: you
are free to use the `initialize` method just as you would in any
normal class.

    class Simple < Mustache
      include ViewHelpers

      def initialize(ssl = false)
        @ssl = ssl
      end

      ... etc ...
    end

Now:

    Simple.new(request.ssl?).render

Convoluted but you get the idea.


Sinatra
-------

Mustache ships with Sinatra integration. Please see
`lib/mustache/sinatra.rb` or
<http://defunkt.github.com/mustache/classes/Mustache/Sinatra.html> for
complete documentation.

An example Sinatra application is also provided:
<http://github.com/defunkt/mustache-sinatra-example>


Vim
---

Thanks to [Juvenn Woo](http://github.com/juvenn) for mustache.vim. It
is included under the contrib/ directory.


Installation
------------

### [Gemcutter](http://gemcutter.org/)

    $ gem install mustache

### [Rip](http://hellorip.com)

    $ rip install git://github.com/defunkt/mustache.git


Acknowledgements
----------------

Thanks to [Tom Preston-Werner](http://github.com/mojombo) for showing
me ctemplate and [Leah Culver](http://github.com/leah) for the name "Mustache."


Meta
----

* Code: `git clone git://github.com/defunkt/mustache.git`
* Home: <http://github.com/defunkt/mustache>
* Docs: <http://defunkt.github.com/mustache>
* Bugs: <http://github.com/defunkt/mustache/issues>
* List: <http://groups.google.com/group/mustache-rb>
* Test: <http://runcoderun.com/defunkt/mustache>
* Gems: <http://gemcutter.org/gems/mustache>
* Boss: Chris Wanstrath :: <http://github.com/defunkt>

[1]: http://code.google.com/p/google-ctemplate/
[2]: http://www.ivan.fomichev.name/2008/05/erlang-template-engine-prototype.html
[3]: http://google-ctemplate.googlecode.com/svn/trunk/doc/howto.html
