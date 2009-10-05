require 'benchmark'

count = (ENV['COUNT'] || 5000).to_i

$benches = []
def bench(name, &block)
  $benches.push([name, block])
end

at_exit do
  Benchmark.bmbm do |x|
    $benches.each do |name, block|
      x.report name.to_s do
        count.times do
          block.call
        end
      end
    end
  end
end
