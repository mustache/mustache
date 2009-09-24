$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'rtemplate'

class Templartial < RTemplate
  self.path = File.dirname(__FILE__)

  def title
    "Welcome"
  end
end

if $0 == __FILE__
  puts Templartial.to_html
end
