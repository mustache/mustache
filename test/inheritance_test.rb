require_relative 'helper'

class InheritanceTest < Minitest::Test

  def test_inheritance_child
    klass = Class.new(Mustache)
    view = klass.new
    view.template_path = File.dirname(__FILE__) + '/fixtures/inheritance'
    view.template_name="sub"
    result = view.render
  end
  
  def test_inheritance_gchild
    klass = Class.new(Mustache)
    view = klass.new
    #klass.template = '{{> test/fixtures/inner_partial}}'
    view.template_path = File.dirname(__FILE__) + '/fixtures/inheritance'
    view.template_name="grandchild"
    result = view.render
    puts "result of redering grandchild"
    puts result
  end
end