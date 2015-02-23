$:.unshift 'lib'

require 'benchmark/ips'
require 'mustache'

template = """
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
"""

data_without_escaping = {
  :external_index=>"product",
  :url=>"/products/7",
  :image=>"products/product.jpg"
}

data_with_escaping = {
  :external_index=>"<h1>Bear > Shark</h1>",
  :url=>"/<h1>Bear > Shark</h1>/7",
  :image=>"products/<h1>Bear > Shark</h1>.jpg"
}

template = Mustache::Template.new(template)

Benchmark.ips do |x|
  x.report("render template without escaping") do |times|
    ctx = Mustache::Context.new(Mustache.new); ctx.push(data_without_escaping)
    template.render(ctx)
  end

  x.report("render template with escaping") do |times|
    ctx = Mustache::Context.new(Mustache.new); ctx.push(data_with_escaping)
    template.render(ctx)
  end
end
