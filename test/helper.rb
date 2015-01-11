require 'minitest/autorun'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

Dir[File.dirname(__FILE__) + '/fixtures/*.rb'].each do |f|
  require f
end
