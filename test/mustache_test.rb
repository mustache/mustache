require 'test/unit'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../examples'
require 'simple'
require 'complex_view'
require 'view_partial'
require 'template_partial'
require 'escaped'
require 'unescaped'
require 'comments'
require 'passenger'

class MustacheTest < Test::Unit::TestCase

  def test_passenger
    assert_equal <<-end_passenger, Passenger.to_text
<VirtualHost *>
  ServerName example.com
  DocumentRoot /var/www/example.com
  RailsEnv production
</VirtualHost>
end_passenger
  end

  def test_complex_view
    assert_equal <<-end_complex, ComplexView.render
<h1>Colors</h1>
  <ul>
      <li><strong>red</strong></li>
      <li><a href="#Green">green</a></li>
      <li><a href="#Blue">blue</a></li>
  </ul>
end_complex
  end

  def test_simple
    assert_equal <<-end_simple, Simple.render
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

    assert_equal <<-end_simple, view.render
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

    assert_equal <<-end_simple, view.render
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

    assert_equal 'Hi mom!', view.render
  end

  def test_view_partial
    assert_equal <<-end_partial.strip, ViewPartial.render
<h1>Welcome</h1>
Hello Chris
You have just won $10000!
Well, $6000.0, after taxes.

<h3>Fair enough, right?</h3>
end_partial
  end

  def test_template_partial
    assert_equal <<-end_partial.strip, TemplatePartial.render
<h1>Welcome</h1>
Again, Welcome!
end_partial
  end

  def test_template_partial_with_custom_extension
    partial = TemplatePartial.new
    partial.template_extension = 'txt'

    assert_equal <<-end_partial.strip, partial.render
Welcome
-------

## Again, Welcome! ##
end_partial
  end

  def test_comments
    assert_equal "<h1>A Comedy of Errors</h1>\n", Comments.render
  end

  def test_escaped
    assert_equal '<h1>Bear &gt; Shark</h1>', Escaped.render
  end

  def test_unescaped
    assert_equal '<h1>Bear > Shark</h1>', Unescaped.render
  end

  def test_classify
    assert_equal 'TemplatePartial', Mustache.classify('template_partial')
  end

  def test_underscore
    assert_equal 'template_partial', Mustache.underscore('TemplatePartial')
  end

  def test_namespaced_underscore
    assert_equal 'stat_stuff', Mustache.underscore('Views::StatStuff')
  end

  def test_render
    assert_equal 'Hello World!', Mustache.render('Hello World!')
  end

  def test_render_with_params
    assert_equal 'Hello World!', Mustache.render('Hello {{planet}}!', :planet => 'World')
  end

  def test_render_from_file
    expected = <<-data
<VirtualHost *>
  ServerName example.com
  DocumentRoot /var/www/example.com
  RailsEnv production
</VirtualHost>
data
    template = File.read("examples/passenger.conf")
    assert_equal expected, Mustache.render(template, :stage => 'production',
                                                     :server => 'example.com',
                                                     :deploy_to => '/var/www/example.com' )
  end

end
