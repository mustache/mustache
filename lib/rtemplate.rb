class RTemplate
  # Helper method for quickly instantiating and rendering a view.
  def self.to_html
    new.to_html
  end

  # The path informs your RTemplate subclass where to look for its
  # corresponding template.
  def self.path=(path)
    @path = File.expand_path(path)
  end

  def self.path
    @path || '.'
  end

  # Templates are self.class.name.downcase + '.html' -- a class of
  # Dashboard would have a template (relative to the path) of
  # dashboard.html
  def template
    self.class.path + '/' + self.class.to_s.downcase + '.html'
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
    @context
  end

  # How we turn a view object into HTML. The main method, if you will.
  def to_html
    render File.read(template)
  end

  # Parses our fancy pants, template HTML and returns normal HTMl with
  # all special {{tags}} and {{#sections}}replaced{{/sections}}.
  def render(html, context = {})
    # Set the context so #find and #context have access to it
    @context = context

    debug do
      puts "in:"
      puts html.inspect
      puts context.inspect
    end

    # {{#sections}}okay{{/sections}}
    #
    # Sections can return true, false, or an enumerable.
    # If true, the section is displayed.
    # If false, the section is not displayed.
    # If enumerable, the return value is iterated over (a for loop).
    html = html.gsub(/\{\{\#(.+)\}\}\s*(.+)\{\{\/\1\}\}\s*/m) do |s|
      ret = find($1)

      if ret.respond_to? :each
        ret.map do |ctx|
          # iterated sections inherit their parent context
          render($2, context.merge(ctx)).to_s
        end
      elsif ret
        # render the section with the present context
        render($2, context).to_s
      else
        ''
      end
    end

    # Re-set the @context because our recursion probably overwrote it
    @context = context
    html = html.gsub(/\{\{([^\/#]+?)\}\}/) { find($1) }

    debug do
      puts "out:"
      puts html.inspect
    end

    html
  end

  # Given an atom, finds a value. We'll check the current context (for both
  # strings and symbols) then call methods on the view object.
  def find(name)
    if @context.has_key? name
      @context[name]
    elsif @context.has_key? name.to_sym
      @context[name.to_sym]
    elsif respond_to? name
      send name
    else
      raise "Can't find #{name} in #{@context.inspect}"
    end
  end
end
