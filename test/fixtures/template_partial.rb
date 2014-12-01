require 'mustache'

class TemplatePartial < Mustache
  self.path = File.dirname(__FILE__)

  def title
    "Welcome"
  end

  def title_bars
    '-' * title.size
  end
end

if $0 == __FILE__
  puts TemplatePartial.to_html
end
