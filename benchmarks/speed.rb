require 'erb'

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../examples'
require 'complex_view'

## erb
template = File.read(File.dirname(__FILE__) + '/complex.erb')

unless ENV['NOERB']
  erb =  ERB.new(template)
  scope = ComplexView.new.send(:binding)
  bench 'ERB  w/ caching' do
    erb.result(scope)
  end

  unless ENV['CACHED']
    scope = ComplexView.new.send(:binding)
    bench 'ERB  w/o caching' do
      ERB.new(template).result(scope)
    end
  end
end


## haml
require 'haml'
template = File.read(File.dirname(__FILE__) + '/complex.haml')

unless ENV['NOHAML']
  haml = Haml::Engine.new(template)
  scope = ComplexView.new.send(:binding)
  bench 'HAML w/ caching' do
    haml.render(scope)
  end

  unless ENV['CACHED']
    scope = ComplexView.new.send(:binding)
    bench 'HAML w/o caching' do
      Haml::Engine.new(template).render(scope)
    end
  end
end


## mustache
tpl = ComplexView.new
tpl.template

tpl[:header] = 'Chris'
tpl[:empty] = false
tpl[:list] = true

items = []
items << { :name => 'red', :current => true, :url => '#Red' }
items << { :name => 'green', :current => false, :url => '#Green' }
items << { :name => 'blue', :current => false, :url => '#Blue' }

tpl[:item] = items

bench '{{   w/ caching' do
  tpl.to_html
end

content = File.read(ComplexView.template_file)

unless ENV['CACHED']
  bench '{{   w/o caching' do
    ctpl = ComplexView.new
    ctpl.template = content
    ctpl[:item] = items
    ctpl.to_html
  end
end
