$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'i18n'
require 'mustache'

I18n.backend.store_translations(
  :en,
  :mustache => {
    :title => 'Bear > Shark',
    :body => '<p>Unless the shark has {{item}}.</p>'
  }
)

class Translation < Mustache
  self.path = File.dirname(__FILE__)

  def item
    'laser beams'
  end

  def exclamation
    "PEW PEW!"
  end

end

if $0 == __FILE__
  puts Translation.to_html
end
