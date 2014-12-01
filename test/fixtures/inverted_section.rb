require 'mustache'

class InvertedSection < Mustache
  self.path = File.dirname(__FILE__)

  def t
    false
  end

  def two
    "second"
  end
end
