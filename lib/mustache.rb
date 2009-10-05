require 'cgi'

class Mustache
  # A Template is a compiled version of a Mustache template.
  class Template
    def initialize(source, template_path)
      @source = source
      @template_path = template_path
      @tmpid = 0
    end

    def render(context)
      class << self; self; end.class_eval <<-EOF, __FILE__, __LINE__ - 1
        def render(ctx)
          #{compile}
        end
      EOF
      render(context)
    end

    def compile(src = @source)
      "\"#{compile_sections(src)}\""
    end

  private
    # {{#sections}}okay{{/sections}}
    #
    # Sections can return true, false, or an enumerable.
    # If true, the section is displayed.
    # If false, the section is not displayed.
    # If enumerable, the return value is iterated over (a for loop).
    def compile_sections(src)
      res = ""
      while src =~ /^\s*\{\{\#(.+)\}\}\n*(.+)^\s*\{\{\/\1\}\}\n*/m
        res << compile_tags($`)
        name = $1.strip.to_sym.inspect
        code = compile($2)
        ctxtmp = "ctx#{tmpid}"
        res << ev("(v = ctx[#{name}]) ? v.respond_to?(:each) ? "\
          "(#{ctxtmp}=ctx.dup; r=v.map{|h|ctx.merge!(h);#{code}}.join; "\
          "ctx.replace(#{ctxtmp});r) : #{code} : ''")
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
        ev("#{klass}.to_html")
      else
        src = File.read(@template_path + '/' + name + '.html')
        compile(src)[1..-2]
      end
    end

    # Generate a temporary id.
    def tmpid
      @tmpid += 1
    end

    def str(s)
      s.inspect[1..-2]
    end

    def etag(s)
      ev("Mustache.escape(ctx[#{s.strip.to_sym.inspect}])")
    end

    def utag(s)
      ev("ctx[#{s.strip.to_sym.inspect}]")
    end

    def ev(s)
      "#\{#{s}}"
    end
  end

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
        raise "Can't find #{name} in #{inspect}"
      end
    end
  end

  # Helper method for quickly instantiating and rendering a view.
  def self.to_html
    new.to_html
  end

  # The path informs your Mustache subclass where to look for its
  # corresponding template.
  def self.path=(path)
    @path = File.expand_path(path)
  end

  def self.path
    @path || '.'
  end

  # Templates are self.class.name.underscore + '.html' -- a class of
  # Dashboard would have a template (relative to the path) of
  # dashboard.html
  def self.template_file
    @template_file ||= path + '/' + underscore(to_s) + '.html'
  end

  def self.template_file=(template_file)
    @template_file = template_file
  end

  def self.template
    @template ||= templateify(File.read(template_file))
  end

  # template_partial => TemplatePartial
  def self.classify(underscored)
    underscored.split(/[-_]/).map { |part| part[0] = part[0].chr.upcase; part }.join
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

  def self.templateify(obj)
    obj.is_a?(Template) ? obj : Template.new(obj.to_s, path)
  end

  # The template itself. You can override this if you'd like.
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

  # How we turn a view object into HTML. The main method, if you will.
  def to_html
    render template
  end

  # Parses our fancy pants template HTML and returns normal HTML with
  # all special {{tags}} and {{#sections}}replaced{{/sections}}.
  def render(html, ctx = {})
    html = self.class.templateify(html)
    html.render(context.update(ctx))
  end
end
