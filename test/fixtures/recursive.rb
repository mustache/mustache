require 'mustache'

class Recursive < Mustache
  self.path = File.dirname(__FILE__)

  def show
    false
  end
end

if $0 == __FILE__
  puts Recursive.to_html
end
