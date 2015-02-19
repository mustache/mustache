$:.unshift 'lib'

require 'benchmark/ips'
require 'mustache'

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

Benchmark.ips do |x|
  x.report("Compile template") do |times|
    Mustache::Template.new(template).compile
  end
end
