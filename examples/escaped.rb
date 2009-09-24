$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'rtemplate'

class Escaped < RTemplate
  self.path = File.dirname(__FILE__)

  def title
    "Bear > Shark"
  end
end

if $0 == __FILE__
  puts Escaped.to_html
end
