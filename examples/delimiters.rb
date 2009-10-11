$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'mustache'

class Delimiters < Mustache
  self.path = File.dirname(__FILE__)

  def first
    "It worked the first time."
  end

  def second
    "And it worked the second time."
  end

  def third
    "Then, surprisingly, it worked the third time."
  end
end

if $0 == __FILE__
  puts Delimiters.to_html
end
