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

# Uncomment to measure object allocations. Requires ruby 2.0.0
# RubyProf.measure_mode = RubyProf::ALLOCATIONS

RubyProf.start

20000.times do
  Mustache::Template.new(template).compile
end

result = RubyProf.stop

printer = RubyProf::GraphHtmlPrinter.new(result)

Pathname.new(FileUtils.pwd).join("benchmarks/compile_template_profile.html").open("w+") do |file|
  printer.print(file, {})
end
