# Usage: ruby data.rb > data.yml
#
# Generates data.yml for use with index.mustache

require 'hpricot'
require 'open-uri'
require 'yaml'

class Data
  def self.save(file)
    File.open(file, "w") { |f| f.puts build }
  end

  def self.build
    hash.to_yaml + "\---"
  end

  def self.hash
    hash = { 'languages' => [] }
    languages = hash['languages']
    seen = []

    doc = Hpricot(open"http://wiki.github.com/defunkt/mustache/")
    doc.search(".wikistyle li").each do |lib|
      lang = lib.innerText.scan(/\(.+?\)/).to_s.gsub(/\(|\)/, '')
      next if seen.include?(lang)
      seen << lang

      link = lib.at('a')['href']
      languages << { :url => link, :name => lang }

      # node is special
      if lang == "node.js"
        hash['last_language'] = languages.pop
      end
    end

    hash
  end
end

if $0 == __FILE__
  puts Data.build
#   puts YAML.load(Data.build.to_s).inspect
end
