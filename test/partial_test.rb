$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class PartialTest < Test::Unit::TestCase
  def test_view_partial
    assert_equal <<-end_partial.strip, PartialWithModule.render
<h1>Welcome</h1>
Hello Bob
You have just won $100000!

<h3>Fair enough, right?</h3>
end_partial
  end

  def test_view_partial_inherits_context
    klass = Class.new(TemplatePartial)
    klass.template_path = File.dirname(__FILE__) + '/../examples'
    view = klass.new
    view[:titles] = [{:title => :One}, {:title => :Two}]
    view.template = <<-end_template
<h1>Context Test</h1>
<ul>
{{#titles}}
<li>{{>inner_partial}}</li>
{{/titles}}
</ul>
end_template
    assert_equal <<-end_partial, view.render
<h1>Context Test</h1>
<ul>
<li>Again, One!</li>
<li>Again, Two!</li>
</ul>
end_partial
  end

  def test_view_partial_inherits_context_of_class_methods
    klass = Class.new(TemplatePartial)
    klass.template_path = File.dirname(__FILE__) + '/../examples'
    klass.send(:define_method, :titles) do
      [{:title => :One}, {:title => :Two}]
    end
    view = klass.new
    view.template = <<-end_template
<h1>Context Test</h1>
<ul>
{{#titles}}
<li>{{>inner_partial}}</li>
{{/titles}}
</ul>
end_template
    assert_equal <<-end_partial, view.render
<h1>Context Test</h1>
<ul>
<li>Again, One!</li>
<li>Again, Two!</li>
</ul>
end_partial
  end

  def test_template_partial
    assert_equal <<-end_partial.strip, TemplatePartial.render
<h1>Welcome</h1>
Again, Welcome!
end_partial
  end

  def test_template_partial_with_custom_extension
    partial = Class.new(TemplatePartial)
    partial.template_extension = 'txt'
    partial.template_path = File.dirname(__FILE__) + '/../examples'

    assert_equal <<-end_partial.strip, partial.render.strip
Welcome
-------

## Again, Welcome! ##
end_partial
  end
end
