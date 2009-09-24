$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'rtemplate'

class Partial < RTemplate
  self.path = File.dirname(__FILE__)

  def greeting
    "Welcome"
  end

  def farewell
    "Fair enough, right?"
  end
end

if $0 == __FILE__
  puts Partial.to_html
end
