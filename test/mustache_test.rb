require 'test/unit'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../examples'
require 'simple'
require 'complex_view'
require 'view_partial'
require 'template_partial'
require 'escaped'
require 'unescaped'
require 'comments'

class MustacheTest < Test::Unit::TestCase
  def test_complex_view
    assert_equal <<-end_complex, ComplexView.to_html
<h1>Colors</h1>
<ul>
  <li><strong>red</strong></li>
    <li><a href="#Green">green</a></li>
    <li><a href="#Blue">blue</a></li>
    </ul>
end_complex
  end

  def test_simple
    assert_equal <<-end_simple, Simple.to_html
Hello Chris
You have just won $10000!
Well, $6000.0, after taxes.
end_simple
  end

  def test_hash_assignment
    view = Simple.new
    view[:name]  = 'Bob'
    view[:value] = '4000'
    view[:in_ca] = false

    assert_equal <<-end_simple, view.to_html
Hello Bob
You have just won $4000!
end_simple
  end

  def test_crazier_hash_assignment
    view = Simple.new
    view[:name]  = 'Crazy'
    view[:in_ca] = [
      { :taxed_value => 1 },
      { :taxed_value => 2 },
      { :taxed_value => 3 },
    ]

    assert_equal <<-end_simple, view.to_html
Hello Crazy
You have just won $10000!
Well, $1, after taxes.
Well, $2, after taxes.
Well, $3, after taxes.
end_simple
  end

  def test_fileless_templates
    view = Simple.new
    view.template = 'Hi {{person}}!'
    view[:person]  = 'mom'

    assert_equal 'Hi mom!', view.to_html
  end

  def test_view_partial
    assert_equal <<-end_partial.strip, ViewPartial.to_html
<h1>Welcome</h1>
Hello Chris
You have just won $10000!
Well, $6000.0, after taxes.

<h3>Fair enough, right?</h3>
end_partial
  end

  def test_template_partial
    assert_equal <<-end_partial.strip, TemplatePartial.to_html
<h1>Welcome</h1>
Again, Welcome!
end_partial
  end

  def test_comments
    assert_equal "<h1>A Comedy of Errors</h1>\n", Comments.to_html
  end

  def test_escaped
    assert_equal '<h1>Bear &gt; Shark</h1>', Escaped.to_html
  end

  def test_unescaped
    assert_equal '<h1>Bear > Shark</h1>', Unescaped.to_html
  end

  def test_classify
    assert_equal 'TemplatePartial', Mustache.new.classify('template_partial')
  end

  def test_underscore
    assert_equal 'template_partial', Mustache.new.underscore('TemplatePartial')
  end

  def test_namespaced_underscore
    assert_equal 'stat_stuff', Mustache.new.underscore('Views::StatStuff')
  end
end
