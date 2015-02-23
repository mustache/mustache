$:.unshift 'lib'

require "ruby-prof"
require 'mustache'
require "pathname"

template = """
{{#products}}
  <div class='product_brick'>
    <div class='container'>
      <div class='element'>
        <img src='images/{{image}}' class='product_miniature' />
      </div>
      <div class='element description'>
        <a href={{url}} class='product_name block bold'>
          {{external_index}}
        </a>
      </div>
    </div>
  </div>
{{/products}}
"""


data = {
  products: []
}

200.times do
  data[:products] << {
    :external_index=>"product",
    :url=>"/products/7",
    :image=>"products/product.jpg"
  }
end

# Uncomment to measure object allocations. Requires ruby 2.0.0
# RubyProf.measure_mode = RubyProf::ALLOCATIONS

RubyProf.start

500.times do
  Mustache.render(template, data)
end

result = RubyProf.stop

printer = RubyProf::GraphHtmlPrinter.new(result)

Pathname.new(FileUtils.pwd).join("benchmarks/render_collection_profile.html").open("w+") do |file|
  printer.print(file, {})
end
