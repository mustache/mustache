class RTemplate
  def self.to_html
    new.to_html
  end

  def debug
    yield if ENV['DEBUG']
  end

  def context
    @context
  end

  def to_html
    render File.read(template)
  end

  def render(html, context = {})
    @context = context

    debug do
      puts "in:"
      puts html.inspect
      puts context.inspect
    end

    html = html.gsub(/\{\{\#(.+)\}\}\s*(.+)\{\{\/\1\}\}\s*/m) do |s|
      ret = find($1)

      if ret.respond_to? :each
        ret.map do |ctx|
          render($2, context.merge(ctx)).to_s
        end
      elsif ret
        render($2, context).to_s
      else
        ''
      end
    end

    @context = context
    html = html.gsub(/\{\{([^\/#]+?)\}\}/) { find($1) }

    debug do
      puts "out:"
      puts html.inspect
    end

    html
  end

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

  def template
    self.class.to_s.downcase + '.html'
  end
end
