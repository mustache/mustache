require 'cgi'

# Blah blah blah?
# who knows.
class Mustache
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
  def template_file
    @template_file ||= self.class.path + '/' + underscore(self.class.to_s) + '.html'
  end

  def template_file=(template_file)
    @template_file = template_file
  end

  # The template itself. You can override this if you'd like.
  def template
    @template ||= File.read(template_file)
  end

  def template=(template)
    @template = template
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
    @context ||= {}
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
  def render(html, context = {})
    # Set the context so #find and #context have access to it
    @context = context = (@context || {}).merge(context)

    html = render_sections(html)

    # Re-set the @context because our recursion probably overwrote it
    @context = context

    render_tags(html)
  end

  # {{#sections}}okay{{/sections}}
  #
  # Sections can return true, false, or an enumerable.
  # If true, the section is displayed.
  # If false, the section is not displayed.
  # If enumerable, the return value is iterated over (a for loop).
  def render_sections(template)
    # fail fast
    return template unless template.include?('{{#')

    template.gsub(/\{\{\#(.+)\}\}\s*(.+)\{\{\/\1\}\}\s*/m) do |s|
      ret = find($1)

      if ret.respond_to? :each
        ret.map do |ctx|
          render($2, ctx)
        end.join
      elsif ret
        render($2)
      else
        ''
      end
    end
  end

  # Find and replace all non-section tags.
  # In particular we look for four types of tags:
  # 1. Escaped variable tags - {{var}}
  # 2. Unescaped variable tags - {{{var}}}
  # 3. Comment variable tags - {{! comment}
  # 4. Partial tags - {{< partial_name }}
  def render_tags(template)
    # fail fast
    return template unless template.include?('{{')

    template.gsub(/\{\{(!|<|\{)?([^\/#]+?)\1?\}\}+/) do
      case $1

      when '!'
        # Comments are ignored
        ''

      when '<'
        # Partials are pulled in relative to `path`
        partial($2)

      when '{'
        # The triple mustache is unescaped.
        find($2)

      else
        # The double mustache is escaped.
        escape find($2)

      end
    end
  end

  # Partials are basically a way to render views from inside other views.
  def partial(name)
    # First we check if a partial's view class already exists
    klass = classify(name)

    if Object.const_defined? klass
      # If so we can cheat and render that
      Object.const_get(klass).to_html
    else
      # If not we need to render the file directly.
      render File.read(self.class.path + '/' + name + '.html'), context
    end
  end

  # template_partial => TemplatePartial
  def classify(underscored)
    underscored.split(/[-_]/).map { |part| part[0] = part[0].chr.upcase; part }.join
  end

  # TemplatePartial => template_partial
  def underscore(classified)
    string = classified.dup.split('::').last
    string[0] = string[0].chr.downcase
    string.gsub(/[A-Z]/) { |s| "_#{s.downcase}"}
  end

  # Escape HTML.
  def escape(string)
    CGI.escapeHTML(string.to_s)
  end

  # Given an atom, finds a value. We'll check the current context (for both
  # strings and symbols) then call methods on the view object.
  def find(name)
    name.strip!
    if @context.has_key? name.to_sym
      @context[name.to_sym]
    elsif respond_to? name
      send name
    else
      raise "Can't find #{name} in #{@context.inspect}"
    end
  end
end
