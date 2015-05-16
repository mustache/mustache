$:.unshift "lib"

require "mustache"
require "benchmark/ips"

BASE_TEMPLATE = <<end_of_template
<h2>Names</h2>
{{#names}}
  {{> user}}
{{/names}}
end_of_template

PARTIAL_TEMPLATE = <<end_of_template
<strong>{{name}}</strong>
end_of_template

one_name = [
  {name: "Charlie Chaplin"},
]

data_10 = {
  names: one_name * 10,
}

data_100 = {
  names: one_name * 100,
}

data_1000 = {
  names: one_name * 1000,
}

class Custom < Mustache
  def partial(name)
    PARTIAL_TEMPLATE
  end
end

mustache = Custom.new
mustache.template = BASE_TEMPLATE

Benchmark.ips do |x|
  x.report("render list of 10") do
    mustache.render(data_10)
  end

  x.report("render list of 100") do
    mustache.render(data_100)
  end

  x.report("render list of 1000") do
    mustache.render(data_1000)
  end
end
