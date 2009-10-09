require 'sinatra/base'
require 'mustache'

class Mustache
  # Support for Mustache in your Sinatra app.
  #
  #   require 'mustache/sinatra'
  #
  #   class App < Sinatra::Base
  #     # Should be the path to your .mustache template files.
  #     set :views, "path/to/mustache/templates"
  #
  #     # Should be the path to your .rb Mustache view files.
  #     # Only needed if different from the `views` setting
  #     set :mustaches, "path/to/mustache/views"
  #
  #     # This tells Mustache where to look for the Views modules,
  #     # under which your View classes should live. By default it's
  #     # Object. That is, for an :index view Mustache will expect
  #     # Views::Index. In this example, we're telling Mustache to look
  #     # for index at App::Views::Index.
  #     set :namespace, App
  #
  #     get '/stats' do
  #       mustache :stats
  #     end
  #   end
  #
  # As noted above, Mustache will look for `App::Views::Index` when
  # `mustache :index` is called.
  #
  # If no `Views::Stats` class exists Mustache will render the template
  # file directly.
  #
  # You can indeed use layouts with this library. Where you'd normally
  # <%= yield %> you instead {{{yield}}} - the body of the subview is
  # set to the `yield` variable and made available to you.
  module Sinatra
    # Call this in your Sinatra routes.
    def mustache(template, options={}, locals={})
      render :mustache, template, options, locals
    end

    # This is called by Sinatra's `render` with the proper paths
    # and, potentially, a block containing a sub-view
    def render_mustache(template, data, options, locals, &block)
      name = Mustache.classify(template.to_s)

      # This is a horrible hack but we need it to know under which namespace
      # Views is located. If you have Haystack::Views, namespace should be
      # set to Haystack.
      namespace = self.class.namespace

      if namespace.const_defined?(:Views) && namespace::Views.const_defined?(name)
        # First try to find the existing view,
        # e.g. Haystack::Views::Index
        klass = namespace::Views.const_get(name)

      elsif File.exists?(file = "#{self.class.mustaches}/#{template}.rb")
        # Couldn't find it - try to require the file if it exists, then
        # load in the view.
        require "#{file}".chomp('.rb')
        klass = namespace::Views.const_get(name)

      else
        # Still nothing. Use the stache.
        klass = Mustache

      end

      # Create a new instance for playing with
      instance = klass.new

      # Copy instance variables set in Sinatra to the view
      instance_variables.each do |name|
        instance.instance_variable_set(name, instance_variable_get(name))
      end

      # Locals get added to the view's context
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

Sinatra::Base.helpers Mustache::Sinatra
Sinatra::Base.set :mustaches, Sinatra::Base.views
Sinatra::Base.set :namespace, Object
