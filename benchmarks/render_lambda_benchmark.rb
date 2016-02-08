$:.unshift "lib"

require "mustache"
require "benchmark/ips"

BASE_TEMPLATE = <<end_of_template
<h2>Lambdas</h2>
{{#lambdas}}
  {{#lambda}}
    Here is some text inside the lambda.\n
    Also a variable is present: {{name}}.
  {{/lambda}}
{{/lambdas}}
end_of_template

one_name = [
  {
    name: "Charlie Chaplin",
    lambda: lambda {|text| "\n--\n#{text}\n--\n" }
  },
]

data_10 = {
  lambdas: one_name * 10,
}

data_100 = {
  lambdas: one_name * 100,
}

data_1000 = {
  lambdas: one_name * 1000,
}

mustache = Mustache.new
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
