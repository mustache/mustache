# -*- coding: utf-8 -*-

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class GeneratorExtensionsTest < Test::Unit::TestCase
  def test_extension_without_args
    klass = Class.new(Mustache)
    klass.template = "It is now : {{_date}}"
    assert_equal "It is now : 2011-07-22 13:40:47 +0200", klass.render
  end

  def test_extension_with_args_and_escaped
    klass = Class.new(Mustache)
    klass.template = "{{_i18n.fr.name}}: The Doctor"
    assert_equal "&gt; Nom: The Doctor", klass.render
  end
  
  def test_extension_with_args_and_not_escaped
    klass = Class.new(Mustache)
    klass.template = "Pays: {{{_i18n.fr.in_my_country_link}}}"
    assert_equal 'Pays: <a href="/france">Dans mon pays</a>', klass.render
  end
end
