require 'erb'

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../examples'
require 'complex_view'

## erb
template = File.read(File.dirname(__FILE__) + '/complex.erb')

unless ENV['NOERB']
  erb =  ERB.new(template)
  bench 'ERB w/ caching' do
    erb.result(ComplexView.new.send(:binding))
  end

  bench 'ERB w/o caching' do
    ERB.new(template).result(ComplexView.new.send(:binding))
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

bench '{ w/ caching' do
  tpl.to_html
end

content = File.read(ComplexView.template_file)

unless ENV['CACHED']
  bench '{ w/o caching' do
    ctpl = ComplexView.new
    ctpl.template = content
    ctpl[:item] = items
    ctpl.to_html
  end
end
