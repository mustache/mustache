# Support for Mustache in your Sinatra app.
#
# require 'mustache/sinatra'
#
# class App < Sinatra::Base
#   include Mustache::Sinatra
# end
require 'mustache'

class Mustache
  module Sinatra
    def mustache(template, options={}, locals={})
      render :mustache, template, options, locals
    end

    def render_mustache(template, data, options, locals, &block)
      name = Mustache.new.classify(template.to_s)

      if defined?(Views) && Views.const_defined?(name)
        instance = Views.const_get(name).new
      else
        instance = Mustache.new
      end

      locals.each do |local, value|
        instance[local] = value
      end

      instance[:yield] = block.call if block

      instance.template = data
      instance.to_html
    end
  end
end
