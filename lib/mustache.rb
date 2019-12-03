require 'mustache/enumerable'
require 'mustache/template'
require 'mustache/context'
require 'mustache/settings'
require 'mustache/utils'

# Mustache is the base class from which your Mustache subclasses
# should inherit (though it can be used on its own).
#
# The typical Mustache workflow is as follows:
#
# * Create a Mustache subclass: class Stats < Mustache
# * Create a template: stats.mustache
# * Instantiate an instance: view = Stats.new
# * Render that instance: view.render
#
# You can skip the instantiation by calling `Stats.render` directly.
#
# While Mustache will do its best to load and render a template for
# you, this process is completely customizable using a few options.
#
# All settings can be overriden at the class level.
#
# For example, going with the above example, we can use
# `Stats.template_path = "/usr/local/templates"` to specify the path
# Mustache uses to find templates.
#
# Here are the available options:
#
# * template_path
#
# The `template_path` setting determines the path Mustache uses when
# looking for a template. By default it is "."
# Setting it to /usr/local/templates, for example, means (given all
# other settings are default) a Mustache subclass `Stats` will try to
# load /usr/local/templates/stats.mustache
#
# * template_extension
#
# The `template_extension` is the extension Mustache uses when looking
# for template files. By default it is "mustache"
#
# * template_file
#
# You can tell Mustache exactly which template to use with this
# setting. It can be a relative or absolute path.
#
# * template
#
# Sometimes you want Mustache to render a string, not a file. In those
# cases you may set the `template` setting. For example:
#
#   >> Mustache.render("Hello {{planet}}", :planet => "World!")
#   => "Hello World!"
#
# The `template` setting is also available on instances.
#
#   view = Mustache.new
#   view.template = "Hi, {{person}}!"
#   view[:person] = 'Mom'
#   view.render # => Hi, mom!
#
# * view_namespace
#
# To make life easy on those developing Mustache plugins for web frameworks or
# other libraries, Mustache will attempt to load view classes (i.e. Mustache
# subclasses) using the `view_class` class method. The `view_namespace` tells
# Mustache under which constant view classes live. By default it is `Object`.
#
# * view_path
#
# Similar to `template_path`, the `view_path` option tells Mustache where to look
# for files containing view classes when using the `view_class` method.
#
class Mustache

  # Initialize a new Mustache instance.
  #
  # @param [Hash] options An options hash
  # @option options [String] template_path 
  # @option options [String] template_extension
  # @option options [String] template_file
  # @option options [String] template
  # @option options [String] view_namespace 
  # @option options [String] view_path
  def initialize(options = {})
    @options = options
    
    initialize_settings
  end

  # Instantiates an instance of this class and calls `render` with
  # the passed args.
  #
  # @return A rendered String version of a template.
  def self.render(*args)
    new.render(*args)
  end

  # Parses our fancy pants template file and returns normal file with
  # all special {{tags}} and {{#sections}}replaced{{/sections}}.
  #
  # @example Render view
  #   @view.render("Hi {{thing}}!", :thing => :world)
  #
  # @example Set view template and then render
  #   View.template = "Hi {{thing}}!"
  #   @view = View.new
  #   @view.render(:thing => :world)
  #
  # @param [String,Hash] data A String template or a Hash context.
  #                           If a Hash is given, we'll try to figure
  #                           out the template from the class.
  # @param [Hash] ctx A Hash context if `data` is a String template.
  # @return [String] Returns a rendered version of a template.
  def render(data = template, ctx = {})
    case data
    when Hash
      ctx = data
    when Symbol
      self.template_name = data
    end

    tpl = case data
    when Hash
      templateify(template)
    when Symbol
      templateify(template)
    else
      templateify(data)
    end

    return tpl.render(context) if ctx == {}

    begin
      context.push(ctx)
      tpl.render(context)
    ensure
      context.pop
    end
  end

  # Context accessors.
  #
  # @example Context accessors
  #   view = Mustache.new
  #   view[:name] = "Jon"
  #   view.template = "Hi, {{name}}!"
  #   view.render # => "Hi, Jon!"
  def [](key)
    context[key.to_sym]
  end

  def []=(key, value)
    context[key.to_sym] = value
  end

  # A helper method which gives access to the context at a given time.
  # Kind of a hack for now, but useful when you're in an iterating section
  # and want access to the hash currently being iterated over.
  def context
    @context ||= Context.new(self)
  end

  # Given a file name and an optional context, attempts to load and
  # render the file as a template.
  def self.render_file(name, context = {})
    render(partial(name), context)
  end

  # Given a file name and an optional context, attempts to load and
  # render the file as a template.
  def render_file(name, context = {})
    self.class.render_file(name, context)
  end

  # Given a name, attempts to read a file and return the contents as a
  # string. The file is not rendered, so it might contain
  # {{mustaches}}.
  #
  # Call `render` if you need to process it.
  def self.partial(name)
    self.new.partial(name)
  end

  # Override this in your subclass if you want to do fun things like
  # reading templates from a database. It will be rendered by the
  # context, so all you need to do is return a string.
  def partial(name)
    path = "#{template_path}/#{name}.#{template_extension}"

    begin
      File.read(path)
    rescue
      raise if raise_on_context_miss?
      ""
    end
  end

  # Override this to provide custom escaping.
  # By default it uses `CGI.escapeHTML`.
  #
  # @example Overriding #escape
  #   class PersonView < Mustache
  #     def escape(value)
  #       my_html_escape_method(value.to_s)
  #     end
  #   end
  #
  # @param [Object] value Value to escape.
  # @return [String] Escaped content.
  def escape(value)
    self.escapeHTML(value.to_s)
  end
  
  # Override this to provide custom escaping.
  #
  # @example Overriding #escapeHTML
  #   class PersonView < Mustache
  #     def escapeHTML(str)
  #       my_html_escape_method(str)
  #     end
  #   end
  #
  # @deprecated Use {#escape} instead.
  #
  #   Note that {#escape} can receive any kind of object.
  #   If your override logic is expecting a string, you will
  #   have to call to_s on it yourself.
  # @param [String] str String to escape.
  # @return [String] Escaped HTML.
  def escapeHTML(str)
    CGI.escapeHTML(str)
  end

  # Has this instance or its class already compiled a template?
  def compiled?
    (@template && @template.is_a?(Template)) || self.class.compiled?
  end


  private


  # When given a symbol or string representing a class, will try to produce an
  # appropriate view class.
  #
  # @example
  #   Mustache.view_namespace = Hurl::Views
  #   Mustache.view_class(:Partial) # => Hurl::Views::Partial
  def self.view_class(name)
    name = classify(name.to_s)

    # Emptiness begets emptiness.
    return Mustache if name.to_s.empty?

    name = "#{view_namespace}::#{name}"
    const = rescued_const_get(name)

    return const if const

    const_from_file(name)
  end

  def self.rescued_const_get name
    const_get(name, true) || Mustache
  rescue NameError
    nil
  end

  def self.const_from_file name
    file_name = underscore(name)
    file_path = "#{view_path}/#{file_name}.rb"

    return Mustache unless File.exist?(file_path)

    require file_path.chomp('.rb')
    rescued_const_get(name)
  end

  # Has this template already been compiled? Compilation is somewhat
  # expensive so it may be useful to check this before attempting it.
  def self.compiled?
    @template.is_a? Template
  end


  # template_partial => TemplatePartial
  # template/partial => Template::Partial
  def self.classify(underscored)
    Mustache::Utils::String.new(underscored).classify
  end

  # TemplatePartial => template_partial
  # Template::Partial => template/partial
  # Takes a string but defaults to using the current class' name.
  def self.underscore(classified = name)
    classified = superclass.name if classified.to_s.empty?

    Mustache::Utils::String.new(classified).underscore(view_namespace)
  end

  # @param [Template,String] obj      Turns `obj` into a template
  # @param [Hash]            options  Options for template creation
  def self.templateify(obj, options = {})
    obj.is_a?(Template) ? obj : Template.new(obj, options)
  end

  def templateify(obj)
    opts = {:partial_resolver => self.method(:partial)}
    opts.merge!(@options) if @options.is_a?(Hash)
    self.class.templateify(obj, opts)
  end

  # Return the value of the configuration setting on the superclass, or return
  # the default.
  #
  # @param [Symbol] attr_name Name of the attribute. It should match
  #                           the instance variable.
  # @param [Object] default Default value to use if the superclass does
  #                         not respond.
  #
  # @return Inherited or default configuration setting.
  def self.inheritable_config_for(attr_name, default)
    superclass.respond_to?(attr_name) ? superclass.send(attr_name) : default
  end
end
