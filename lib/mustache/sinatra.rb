require 'sinatra/base'
require 'mustache'

class Mustache
  # Support for Mustache in your Sinatra app.
  #
  #   require 'mustache/sinatra'
  #
  #   class Hurl < Sinatra::Base
  #     register Mustache::Sinatra
  #
  #     # Should be the path to your .mustache template files.
  #     set :views, "path/to/mustache/templates"
  #
  #     # Should be the path to your .rb Mustache view files.
  #     # Only needed if different from the `views` setting
  #     set :mustaches, "path/to/mustache/views"
  #
  #     # This tells Mustache where to look for the Views module,
  #     # under which your View classes should live. By default it's
  #     # the class of your app - in this case `Hurl`. That is, for an :index
  #     # view Mustache will expect Hurl::Views::Index by default.
  #
  #     # If our Sinatra::Base subclass was instead Hurl::App,
  #     # we'd want to do `set :namespace, Hurl::App`
  #     set :namespace, Hurl
  #
  #     get '/stats' do
  #       mustache :stats
  #     end
  #   end
  #
  # As noted above, Mustache will look for `Hurl::Views::Index` when
  # `mustache :index` is called.
  #
  # If no `Views::Stats` class exists Mustache will render the template
  # file directly.
  #
  # You can indeed use layouts with this library. Where you'd normally
  # <%= yield %> you instead {{{yield}}} - the body of the subview is
  # set to the `yield` variable and made available to you.
  module Sinatra
    module Helpers
      # Call this in your Sinatra routes.
      def mustache(template, options={}, locals={})
        render :mustache, template, options, locals
      end

      # This is called by Sinatra's `render` with the proper paths
      # and, potentially, a block containing a sub-view
      def render_mustache(template, data, opts, locals, &block)
        name = Mustache.classify(template.to_s)

        # This is a horrible hack but we need it to know under which namespace
        # Views is located. If you have Hurl::App::Views, namespace should be
        # set to Hurl:App.
        namespace = options.namespace

        if namespace.const_defined?(:Views) && namespace::Views.const_defined?(name)
          # First try to find the existing view,
          # e.g. Hurl::Views::Index
          klass = namespace::Views.const_get(name)

        elsif File.exists?(file = "#{options.mustaches}/#{template}.rb")
          # Couldn't find it - try to require the file if it exists, then
          # load in the view.
          require "#{file}".chomp('.rb')
          klass = namespace::Views.const_get(name)

          # compile and cache the template
          klass.template = data

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

        instance.template = data unless instance.compiled?
        instance.to_html
      end
    end

    def self.registered(app)
      app.helpers Mustache::Sinatra::Helpers
      app.set :mustaches, ::Sinatra::Base.views
      app.set :namespace, app
    end
  end
end

Sinatra.register Mustache::Sinatra
