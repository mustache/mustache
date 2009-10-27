require 'test/unit'

module TestViews; end

class AutoloadingTest < Test::Unit::TestCase
  def setup
    Mustache.view_path = File.dirname(__FILE__) + '/../examples'
  end

  def test_autoload
    klass = Mustache.view_class(:Comments)
    assert_equal Comments, klass
  end

  def test_autoload_lowercase
    klass = Mustache.view_class(:comments)
    assert_equal Comments, klass
  end

  def test_namespaced_autoload
    Mustache.view_namespace = TestViews
    klass = Mustache.view_class('Namespaced')
    assert_equal TestViews::Namespaced, klass
    assert_equal <<-end_render.strip, klass.render
<h1>Dragon &lt; Tiger</h1>
end_render
  end
end
