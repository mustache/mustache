# -*- coding: utf-8 -*-
require_relative 'helper'
require 'pathname'

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

  # A single path-like object that is neither a String nor an Array is one path, not a
  # search path. Before 1.1.3 these worked, because the setter was just File.expand_path;
  # Pathname in particular is what jazzy hands us.
  def test_set_path_from_a_pathname
    old_path = Mustache.template_path
    begin
      Mustache.template_path = Pathname.new(File.dirname(__FILE__))
      assert_instance_of Array, Mustache.template_path
      assert_equal [File.expand_path(File.dirname(__FILE__))], Mustache.template_path
    ensure
      Mustache.template_path = old_path
    end
  end

  # A Pathname holding a File::PATH_SEPARATOR is still one path. Only a String is a
  # search path, so this must not be split.
  def test_a_pathname_is_never_split
    old_path = Mustache.template_path
    begin
      dir = File.join(File.dirname(__FILE__), "a#{File::PATH_SEPARATOR}b")
      Mustache.template_path = Pathname.new(dir)
      assert_equal [File.expand_path(dir)], Mustache.template_path
    ensure
      Mustache.template_path = old_path
    end
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
