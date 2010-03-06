task :default => :test

task :test do
  # nothing
end

desc "Build & open index.html in your browser with `open(1)`"
task :open do
  exec "rake build && open index.html"
end

desc "Build the index.html"
task :build do
  exec "ruby -rubygems data.rb > data.yml &&
    cat data.yml index.mustache | mustache > index.html"
end

desc "Print the index.html"
task :print do
  exec "ruby -rubygems data.rb > data.yml &&
    cat data.yml index.mustache | mustache"
end
