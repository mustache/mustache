Mustache
=========

Inspired by [ctemplate](http://code.google.com/p/google-ctemplate/)
and
[et](http://www.ivan.fomichev.name/2008/05/erlang-template-engine-prototype.html),
Mustache is a framework-agnostic way to render logic-free views.

It's not a markup language because there is no language. There is no
logic.


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

    Simple.new.to_html

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


Dict-Style Views
----------------

ctemplate and friends want you to hand a dictionary to the template
processor. Naturally Mustache supports a similar concept. Feel free
to mix the class-based and this more procedural style at your leisure.

Given this template (dict.html):

    Hello {{name}}
    You have just won ${{value}}!

We can fill in the values at will:
    
    dict = Dict.new
    dict[:name] = 'George'
    dict[:value] = 100
    dict.to_html

Which returns:
    
    Hello George
    You have just won $100!

We can re-use the same object, too:

    dict[:name] = 'Tony'
    dict.to_html
    Hello Tony
    You have just won $100!


Templates
---------

A word on templates. By default, a view will try to find its template
on disk by searching for an HTML file in the current directory that
follows the classic Ruby naming convention.

    TemplatePartial => ./template_partial.html
    
You can set the search path using `Mustache.path`. It can be set on a
class by class basis:

    class Simple < Mustache
      self.path = File.dirname(__FILE__)
      ... etc ...
    end

Now `Simple` will look for `simple.html` in the directory it resides
in, no matter the cwd.

If you want to just change what template is used you can set
`Mustache.template_file` directly:

    Simple.template_file = './blah.html'
    
You can also go ahead and set the template directly:

    Simple.template = 'Hi {{person}}!'

You can also set a different template for only a single instance:

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

    Simple.new(request.ssl?).to_html

Convoluted but you get the idea.


Meta
----

* Code: `git clone git://github.com/defunkt/mustache.git`
* Bugs: <http://github.com/defunkt/mustache/issues>
* List: <http://groups.google.com/group/mustache-rb>
* Test: <http://runcoderun.com/defunkt/mustache>
* Boss: Chris Wanstrath :: <http://github.com/defunkt>
