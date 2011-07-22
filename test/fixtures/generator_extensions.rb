$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'mustache'

class Mustache
  class Generator
    def i18n( lang, key )
      @i18n ||= {
        'en' => {
          'name'          => '> Name',
          'title'         => 'Title',
          'in_my_country_link' => '<a href="/uk">In my country</a>'
        },

        'fr' => {
          'name'          => '> Nom',
          'title'         => 'Titre',
          'in_my_country_link' => '<a href="/france">Dans mon pays</a>'
        }
      }

      @i18n[ lang ][ key ]
    end

    def date
      # Time.now
      "2011-07-22 13:40:47 +0200"
    end
  end
end
