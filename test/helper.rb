require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/autorun'

Dir[File.dirname(__FILE__) + '/fixtures/*.rb'].each do |f|
  require f
end
