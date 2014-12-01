require 'mustache'

class DoubleSection < Mustache
  self.path = File.dirname(__FILE__)

  def t
    true
  end

  def two
    "second"
  end
end
