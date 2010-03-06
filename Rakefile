task :default => :test
task :test do
  # nothing
end

desc "Build & open index.html in your browser with `open(1)`"
task :open do
  exec "rake build:html && open index.html"
end

desc "Build JavaScript"
task "build:coffee" do
  sh "coffee --no-wrap *.coffee"
end

desc "Build data.yml"
task "build:data" do
  ruby "-rubygems data.rb > data.yml"
end

desc "Build index.html"
task "build:html" do
  sh "cat data.yml index.mustache | mustache > index.html"
end

desc "Build the whole site"
task :build => [ "build:coffee", "build:data", "build:html" ]

desc "Build and print the index.html"
task :print => "build:html" do
  exec "cat index.html"
end

desc "Publish gh-pages to GitHub"
task :publish do
  exec "rake build && git push origin gh-pages"
end
