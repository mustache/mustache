require 'cgi'

# Mustache is the base class from which your Mustache subclasses
# should inherit (though it can be used on its own).
#
# The typical Mustache workflow is as follows:
#
# * Create a Mustache subclass: class Stats < Mustache
# * Create a template: stats.html
# * Instantiate an instance: view = Stats.new
# * Render that instance: view.render
#
# You can skip the instantiation by calling `Stats.render` directly.
#
# While Mustache will do its best to load and render a template for
# you, this process is completely customizable using a few options.
#
# All settings can be overriden at either the class or instance
# level. For example, going with the above example, we can do either
# `Stats.template_path = "/usr/local/templates"` or
# `view.template_path = "/usr/local/templates"`
#
# Here are the available options:
#
# * template_path
#
# The `template_path` setting determines the path Mustache uses when
# looking for a template. By default it is "."
# Setting it to /usr/local/templates, for example, means (given all
# other settings are default) a Mustache subclass `Stats` will try to
# load /usr/local/templates/stats.html
#
# * template_extension
#
# The `template_extension` is the extension Mustache uses when looking
# for template files. By default it is "html"
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
class Mustache
  # A Template is a compiled version of a Mustache template.
  #
  # The idea is this: when handed a Mustache template, convert it into
  # a Ruby string by transforming Mustache tags into interpolated
  # Ruby.
  #
  # You shouldn't use this class directly.
  class Template
    # Expects a Mustache template as a string along with a template
    # path, which it uses to find partials.
    def initialize(source, template_path)
      @source = source
      @template_path = template_path
      @tmpid = 0
    end

    # Renders the `@source` Mustache template using the given
    # `context`, which should be a simple hash keyed with symbols.
    def render(context)
      # Compile our Mustache template into a Ruby string
      compiled = "def render(ctx) #{compile} end"

      # Here we rewrite ourself with the interpolated Ruby version of
      # our Mustache template so subsequent calls are very fast and
      # can skip the compilation stage.
      instance_eval(compiled, __FILE__, __LINE__ - 1)

      # Call the newly rewritten version of #render
      render(context)
    end

    def compile(src = @source)
      "\"#{compile_sections(src)}\""
    end

    # {{#sections}}okay{{/sections}}
    #
    # Sections can return true, false, or an enumerable.
    # If true, the section is displayed.
    # If false, the section is not displayed.
    # If enumerable, the return value is iterated over (a `for` loop).
    def compile_sections(src)
      res = ""
      while src =~ /^\s*\{\{\#(.+)\}\}\n*(.+)^\s*\{\{\/\1\}\}\n*/m
        # $` = The string to the left of the last successful match
        res << compile_tags($`)
        name = $1.strip.to_sym.inspect
        code = compile($2)
        ctxtmp = "ctx#{tmpid}"
        res << ev("(v = ctx[#{name}]) ? v.respond_to?(:each) ? "\
          "(#{ctxtmp}=ctx.dup; r=v.map{|h|ctx.update(h);#{code}}.join; "\
          "ctx.replace(#{ctxtmp});r) : #{code} : ''")
        # $' = The string to the right of the last successful match
        src = $'
      end
      res << compile_tags(src)
    end

    # Find and replace all non-section tags.
    # In particular we look for four types of tags:
    # 1. Escaped variable tags - {{var}}
    # 2. Unescaped variable tags - {{{var}}}
    # 3. Comment variable tags - {{! comment}
    # 4. Partial tags - {{< partial_name }}
    def compile_tags(src)
      res = ""
      while src =~ /\{\{(!|<|\{)?([^\/#]+?)\1?\}\}+/
        res << str($`)
        case $1
        when '!'
          # ignore comments
        when '<'
          res << compile_partial($2.strip)
        when '{'
          res << utag($2.strip)
        else
          res << etag($2.strip)
        end
        src = $'
      end
      res << str(src)
    end

    # Partials are basically a way to render views from inside other views.
    def compile_partial(name)
      klass = Mustache.classify(name)
      if Object.const_defined?(klass)
        ev("#{klass}.render")
      else
        src = File.read(@template_path + '/' + name + '.html')
        compile(src)[1..-2]
      end
    end

    # Generate a temporary id, used when compiling code.
    def tmpid
      @tmpid += 1
    end

    # Get a (hopefully) literal version of an object, sans quotes
    def str(s)
      s.inspect[1..-2]
    end

    # {{}} - an escaped tag
    def etag(s)
      ev("Mustache.escape(ctx[#{s.strip.to_sym.inspect}])")
    end

    # {{{}}} - an unescaped tag
    def utag(s)
      ev("ctx[#{s.strip.to_sym.inspect}]")
    end

    # An interpolation-friendly version of a string, for use within a
    # Ruby string.
    def ev(s)
      "#\{#{s}}"
    end
  end

  # A Context represents the context which a Mustache template is
  # executed within. All Mustache tags reference keys in the Context.
  class Context < Hash
    def initialize(mustache)
      @mustache = mustache
      super()
    end

    def [](name)
      if has_key?(name)
        super
      elsif @mustache.respond_to?(name)
        @mustache.send(name)
      else
        raise "Can't find #{name} in #{@mustache.inspect}"
      end
    end
  end

  # Helper method for quickly instantiating and rendering a view.
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

  # The template path informs your Mustache subclass where to look for its
  # corresponding template. By default it's the current directory (".")
  def self.template_path
    @template_path ||= '.'
  end

  def self.template_path=(path)
    @template_path = File.expand_path(path)
  end

  class << self
    alias_method :path=, :template_path=
    alias_method :path,  :template_path
  end

  # A Mustache template's default extension is 'html'
  def self.template_extension
    @template_extension ||= 'html'
  end

  def self.template_extension=(template_extension)
    @template_extension = template_extension
  end

  # The template file is the absolute path of the file Mustache will
  # use as its template. By default it's ./class_name.html
  def self.template_file
    @template_file ||= "#{template_path}/#{underscore(to_s)}.#{template_extension}"
  end

  def self.template_file=(template_file)
    @template_file = template_file
  end

  # The template is the actual string Mustache uses as its template.
  def self.template
    @template ||= templateify(File.read(template_file))
  end

  def self.template=(template)
    @template = templateify(template)
  end

  # template_partial => TemplatePartial
  def self.classify(underscored)
    underscored.split(/[-_]/).map do |part|
      part[0] = part[0].chr.upcase; part
    end.join
  end

  # TemplatePartial => template_partial
  def self.underscore(classified)
    string = classified.dup.split('::').last
    string[0] = string[0].chr.downcase
    string.gsub(/[A-Z]/) { |s| "_#{s.downcase}"}
  end

  # Escape HTML.
  def self.escape(string)
    CGI.escapeHTML(string.to_s)
  end

  # Turns a string into a Mustache::Template. If passed a Template,
  # returns it.
  def self.templateify(obj)
    obj.is_a?(Template) ? obj : Template.new(obj.to_s, template_path)
  end

  #
  # Instance level settings
  #

  def template_path
    @template_path ||= self.class.template_path
  end

  def template_path=(template_path)
    @template_path = template_path
  end

  def template_extension
    @template_extension ||= self.class.template_extension
  end

  def template_extension=(template_extension)
    @template_extension = template_extension
  end

  def template_file
    @template_file ||= self.class.template_file
  end

  def template_file=(template_file)
    @template_file = template_file
  end

  def template
    @template ||= self.class.template
  end

  def template=(template)
    @template = self.class.templateify(template)
  end

  # Pass a block to `debug` with your debug putses. Set the `DEBUG`
  # env variable when you want to run those blocks.
  #
  # e.g.
  #  debug { puts @context.inspect }
  def debug
    yield if ENV['DEBUG']
  end

  # A helper method which gives access to the context at a given time.
  # Kind of a hack for now, but useful when you're in an iterating section
  # and want access to the hash currently being iterated over.
  def context
    @context ||= Context.new(self)
  end

  # Context accessors
  def [](key)
    context[key.to_sym]
  end

  def []=(key, value)
    context[key.to_sym] = value
  end

  # Parses our fancy pants template file and returns normal file with
  # all special {{tags}} and {{#sections}}replaced{{/sections}}.
  def render(data = template, ctx = {})
    self.class.templateify(data).render(context.update(ctx))
  end
  alias_method :to_html, :render
  alias_method :to_text, :render
end
