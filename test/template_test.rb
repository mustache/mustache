$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class TemplateTest < Test::Unit::TestCase
  def test_compile
    assert_equal %("foo"), Mustache::Template.new("foo").compile
  end

  def test_compile_with_source
    assert_equal %("bar"), Mustache::Template.new("foo").compile("bar")
  end

  def test_token
    assert_equal [:multi, [:static, "foo"]], Mustache::Template.new("foo").tokens
  end

  def test_token_with_source
    assert_equal [:multi, [:static, "bar"]], Mustache::Template.new("foo").tokens("bar")
  end
end
