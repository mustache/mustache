require 'mustache/template'
require 'mustache/context'

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
# You can tell Mustache exactly which template to us with this
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
  # Instantiates an instance of this class and calls `render` with
  # the passed args.
  #
  # Returns a rendered String version of a template
  def self.render(*args)
    new.render(*args)
  end

  # Alias for `render`
  def self.to_html(*args)
    render(*args)
  end

  # Alias for `render`
  def self.to_text(*args)
    render(*args)
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
    File.read("#{template_path}/#{name}.#{template_extension}")
  end

  # Override this in your subclass if you want to do fun things like
  # reading templates from a database. It will be rendered by the
  # context, so all you need to do is return a string.
  def partial(name)
    self.class.partial(name)
  end

  # The template path informs your Mustache subclass where to look for its
  # corresponding template. By default it's the current directory (".")
  def self.template_path
    @template_path ||= inheritable_config_for :template_path, '.'
  end

  def self.template_path=(path)
    @template_path = File.expand_path(path)
    @template = nil
  end

  # Alias for `template_path`
  def self.path
    template_path
  end

  # Alias for `template_path`
  def self.path=(path)
    self.template_path = path
  end

  # A Mustache template's default extension is 'mustache'
  def self.template_extension
    @template_extension ||= inheritable_config_for :template_extension, 'mustache'
  end

  def self.template_extension=(template_extension)
    @template_extension = template_extension
    @template = nil
  end

  # The template name is the Mustache template file without any
  # extension or other information. Defaults to `class_name`.
  def self.template_name
    @template_name || underscore
  end

  def self.template_name=(template_name)
    @template_name = template_name
    @template = nil
  end

  # The template file is the absolute path of the file Mustache will
  # use as its template. By default it's ./class_name.mustache
  def self.template_file
    @template_file || "#{path}/#{template_name}.#{template_extension}"
  end

  def self.template_file=(template_file)
    @template_file = template_file
    @template = nil
  end

  # The template is the actual string Mustache uses as its template.
  # There is a bit of magic here: what we get back is actually a
  # Mustache::Template object here, but you can still safely use
  # `template=` with a string.
  def self.template
    @template ||= templateify(File.read(template_file))
  end

  def self.template=(template)
    @template = templateify(template)
  end

  # The constant under which Mustache will look for views. By default it's
  # `Object`, but it might be nice to set it to something like `Hurl::Views` if
  # your app's main namespace is `Hurl`.
  def self.view_namespace
    @view_namespace ||= inheritable_config_for(:view_namespace, Object)
  end

  def self.view_namespace=(namespace)
    @view_namespace = namespace
  end

  # Mustache searches the view path for .rb files to require when asked to find a
  # view class. Defaults to "."
  def self.view_path
    @view_path ||= inheritable_config_for(:view_path, '.')
  end

  def self.view_path=(path)
    @view_path = path
  end

  # When given a symbol or string representing a class, will try to produce an
  # appropriate view class.
  # e.g.
  #   Mustache.view_namespace = Hurl::Views
  #   Mustache.view_class(:Partial) # => Hurl::Views::Partial
  def self.view_class(name)
    if name != classify(name.to_s)
      name = classify(name.to_s)
    end

    # Emptiness begets emptiness.
    if name.to_s == ''
      return Mustache
    end

    file_name = underscore(name)
    name = "#{view_namespace}::#{name}"

    if const = const_get!(name)
      const
    elsif File.exists?(file = "#{view_path}/#{file_name}.rb")
      require "#{file}".chomp('.rb')
      const_get!(name) || Mustache
    else
      Mustache
    end
  end

  # Supercharged version of Module#const_get.
  #
  # Always searches under Object and can find constants by their full name,
  #   e.g. Mustache::Views::Index
  #
  # name - The full constant name to find.
  #
  # Returns the constant if found
  # Returns nil if nothing is found
  def self.const_get!(name)
    name.split('::').inject(Object) do |klass, name|
      klass.const_get(name)
    end
  rescue NameError
    nil
  end

  # Should an exception be raised when we cannot find a corresponding method
  # or key in the current context? By default this is false to emulate ctemplate's
  # behavior, but it may be useful to enable when debugging or developing.
  #
  # If set to true and there is a context miss, `Mustache::ContextMiss` will
  # be raised.
  def self.raise_on_context_miss?
    @raise_on_context_miss
  end

  def self.raise_on_context_miss=(boolean)
    @raise_on_context_miss = boolean
  end

  # Has this template already been compiled? Compilation is somewhat
  # expensive so it may be useful to check this before attempting it.
  def self.compiled?
    @template.is_a? Template
  end

  # Has this instance or its class already compiled a template?
  def compiled?
    (@template && @template.is_a?(Template)) || self.class.compiled?
  end

  # template_partial => TemplatePartial
  # template/partial => Template::Partial
  def self.classify(underscored)
    underscored.split('/').map do |namespace|
      namespace.split(/[-_]/).map do |part|
        part[0] = part[0].chr.upcase; part
      end.join
    end.join('::')
  end

  #   TemplatePartial => template_partial
  # Template::Partial => template/partial
  # Takes a string but defaults to using the current class' name.
  def self.underscore(classified = name)
    classified = name if classified.to_s.empty?
    classified = superclass.name if classified.to_s.empty?

    string = classified.dup.split("#{view_namespace}::").last

    string.split('::').map do |part|
      part[0] = part[0].chr.downcase
      part.gsub(/[A-Z]/) { |s| "_#{s.downcase}"}
    end.join('/')
  end

  # Turns a string into a Mustache::Template. If passed a Template,
  # returns it.
  def self.templateify(obj)
    if obj.is_a?(Template)
      obj
    else
      Template.new(obj.to_s)
    end
  end

  # Return the value of the configuration setting on the superclass, or return
  # the default.
  #
  # attr_name - Symbol name of the attribute.  It should match the instance variable.
  # default   - Default value to use if the superclass does not respond.
  #
  # Returns the inherited or default configuration setting.
  def self.inheritable_config_for(attr_name, default)
    superclass.respond_to?(attr_name) ? superclass.send(attr_name) : default
  end

  def templateify(obj)
    self.class.templateify(obj)
  end

  # The template can be set at the instance level.
  def template
    @template ||= self.class.template
  end

  def template=(template)
    @template = templateify(template)
  end

  # Override this to provide custom escaping.
  #
  # class PersonView < Mustache
  #   def escapeHTML(str)
  #     my_html_escape_method(str)
  #   end
  # end
  #
  # Returns a String
  def escapeHTML(str)
    CGI.escapeHTML(str)
  end

  # Instance level version of `Mustache.raise_on_context_miss?`
  def raise_on_context_miss?
    self.class.raise_on_context_miss? || @raise_on_context_miss
  end
  attr_writer :raise_on_context_miss

  # A helper method which gives access to the context at a given time.
  # Kind of a hack for now, but useful when you're in an iterating section
  # and want access to the hash currently being iterated over.
  def context
    @context ||= Context.new(self)
  end

  # Context accessors.
  #
  # view = Mustache.new
  # view[:name] = "Jon"
  # view.template = "Hi, {{name}}!"
  # view.render # => "Hi, Jon!"
  def [](key)
    context[key.to_sym]
  end

  def []=(key, value)
    context[key.to_sym] = value
  end

  # Parses our fancy pants template file and returns normal file with
  # all special {{tags}} and {{#sections}}replaced{{/sections}}.
  #
  # data - A String template or a Hash context. If a Hash is given,
  #        we'll try to figure out the template from the class.
  #  ctx - A Hash context if `data` is a String template.
  #
  # Examples
  #
  #   @view.render("Hi {{thing}}!", :thing => :world)
  #
  #   View.template = "Hi {{thing}}!"
  #   @view = View.new
  #   @view.render(:thing => :world)
  #
  # Returns a rendered String version of a template
  def render(data = template, ctx = {})
    if data.is_a? Hash
      ctx = data
      tpl = templateify(template)
    elsif data.is_a? Symbol
      old_template_name = self.class.template_name
      self.class.template_name = data
      tpl = templateify(template)
      self.class.template_name = old_template_name
    else
      tpl = templateify(data)
    end

    return tpl.render(context) if ctx == {}

    begin
      context.push(ctx)
      tpl.render(context)
    ensure
      context.pop
    end
  end
  alias_method :to_html, :render
  alias_method :to_text, :render
end
