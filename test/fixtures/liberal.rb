require 'mustache'

class Liberal < Mustache
  self.path = File.dirname(__FILE__)

  def first_name
    "kevin"
  end

  def middle_name!
    'j'
  end

  def lastName?
    'sheurs'
  end

  define_method :'street-address' do
    '123 Somewhere St'
  end
end

if $0 == __FILE__
  puts Liberal.to_html
end
