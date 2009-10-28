$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'mustache'

module TestViews
  class Namespaced < Mustache
    self.path = File.dirname(__FILE__)

    def title
      "Dragon < Tiger"
    end
  end

  class NamespacedWithPartial < Mustache
    self.template = "My opinion: {{>MyPartial}}"
  end

  class MyPartial < Mustache
    self.template = "{{exclamation}}!"

    def exclamation
      :Victory
    end
  end
end

if $0 == __FILE__
  puts TestViews::Namespaced.to_html
end
