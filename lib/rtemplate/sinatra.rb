# Support for RTemplate in your Sinatra app.
#
# require 'rtemplate/sinatra'
#
# class App < Sinatra::Base
#   include RTemplate::Sinatra
# end
require 'rtemplate'

class RTemplate
  module Sinatra
    def rtemplate(template, options={}, locals={})
      render :rtemplate, template, options, locals
    end

    def render_rtemplate(template, data, options, locals, &block)
      name = RTemplate.new.classify(template.to_s)

      if defined?(Views) && Views.const_defined?(name)
        instance = Views.const_get(name).new
      else
        instance = RTemplate.new
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
