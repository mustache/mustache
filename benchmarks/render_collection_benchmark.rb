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

data_10 = {
  products: []
}

10.times do
  data_10[:products] << {
    :external_index=>"product",
    :url=>"/products/7",
    :image=>"products/product.jpg"
  }
end

data_100 = {
  products: []
}

100.times do
  data_100[:products] << {
    :external_index=>"product",
    :url=>"/products/7",
    :image=>"products/product.jpg"
  }
end

data_1000 = {
  products: []
}

1000.times do
  data_1000[:products] << {
    :external_index=>"product",
    :url=>"/products/7",
    :image=>"products/product.jpg"
  }
end

Benchmark.ips do |x|
  x.report("render list of 10") do |times|
    Mustache.render(template, data_10)
  end

  x.report("render list of 100") do |times|
    Mustache.render(template, data_100)
  end

  x.report("render list of 1000") do |times|
    Mustache.render(template, data_1000)
  end
end
