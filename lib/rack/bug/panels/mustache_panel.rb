module Rack
  module Bug
    class MustachePanel < Panel
      require "rack/bug/panels/mustache_panel/mustache_extension"

      class View < Mustache
        self.path = ::File.dirname(__FILE__) + '/mustache_panel'

        def times
          MustachePanel.times.map do |key, value|
            { :key => key, :value => value }
          end
        end

        def variables
          MustachePanel.variables.map do |key, value|
            if value.is_a?(Array) && value.size > 10
              size = value.size
              value = value.first(10)
              value << "...and #{size - 10} more"
            end
            { :key => key, :value => value.inspect }
          end
        end
      end

      def self.reset
        Thread.current["rack.bug.mustache.times"] = {}
        Thread.current["rack.bug.mustache.vars"] = {}
      end

      def self.times
        Thread.current["rack.bug.mustache.times"] ||= {}
      end

      def self.variables
        Thread.current["rack.bug.mustache.vars"] ||= {}
      end

      def name
        "mustache"
      end

      def heading
        "{{%.2fms}}" % self.class.times.values.inject(0.0) do |sum, obj|
          sum + obj
        end
      end

      def content
        View.render
      ensure
        self.class.reset
      end
    end
  end
end
