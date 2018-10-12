# -*- coding: utf-8 -*-
require_relative 'helper'

class MustacheTest < Minitest::Test

  def test_default_path
    assert_instance_of Array, Mustache.template_path
    assert_equal 1, Mustache.template_path.size
    assert_includes Mustache.template_path, Dir.pwd
  end

  def test_set_multiple_paths
    old_path = Mustache.template_path
    Mustache.template_path = "this#{File::PATH_SEPARATOR}that"
    assert_instance_of Array, Mustache.template_path
    assert_equal 2, Mustache.template_path.size
    Mustache.template_path = old_path
  end

  def test_override_found

    expected = <<-data
<VirtualHost *>
  ServerAdmin override@mustache.com
  ServerName example.com
  DocumentRoot /var/www/example.com
  RailsEnv production
</VirtualHost>
data
    old_path = Mustache.template_path
    old_extension = Mustache.template_extension

    begin
      base = File.dirname(__FILE__)
      Mustache.template_extension = "conf"
      Mustache.template_path = "#{base}/fixtures/override:#{base}/fixtures"
      assert_equal expected, Mustache.render(:passenger, :stage => 'production',
                                                         :server => 'example.com',
                                                         :deploy_to => '/var/www/example.com')
      Mustache.template_path = "#{base}/fixtures:#{base}/fixtures/override"
      refute_equal expected, Mustache.render(:passenger, :stage => 'production',
                                                         :server => 'example.com',
                                                         :deploy_to => '/var/www/example.com')
    ensure
      Mustache.template_path, Mustache.template_extension = old_path, old_extension
    end
  end

end
