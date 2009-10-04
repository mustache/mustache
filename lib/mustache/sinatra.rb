=begin
Support for Mustache in your Sinatra app.

  require 'mustache/sinatra'

  class App < Sinatra::Base
    helpers Mustache::Sinatra

    get '/stats' do
      mustache :stats
    end
  end

If a `Views::Stats` class exists in the above example,
Mustache will try to instantiate and use it for the rendering.

If no `Views::Stats` class exists Mustache will render the template
file directly.

You can indeed use layouts with this library. Where you'd normally
<%= yield %> you instead {{yield}} - the body of the subview is
set to the `yield` variable and made available to you.
=end
require 'mustache'

class Mustache
  module Sinatra
    # Call this in your Sinatra routes.
    def mustache(template, options={}, locals={})
      render :mustache, template, options, locals
    end

    # This is called by Sinatra's `render` with the proper paths
    # and, potentially, a block containing a sub-view
    def render_mustache(template, data, options, locals, &block)
      name = Mustache.new.classify(template.to_s)

      if defined?(Views) && Views.const_defined?(name)
        instance = Views.const_get(name).new
      else
        instance = Mustache.new
      end

      locals.each do |local, value|
        instance[local] = value
      end

      # If we're paseed a block it's a subview. Sticking it in yield
      # lets us use {{yield}} in layout.html to render the actual page.
      instance[:yield] = block.call if block

      instance.template = data
      instance.to_html
    end
  end
end
