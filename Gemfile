source "https://rubygems.org"

gemspec

module RubyVersion
  def self.rbx?
    defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
  end

  def self.jruby?
    RUBY_PLATFORM =~ /java/
  end
end

gem "benchmark-ips"
gem "bundler"
gem "minitest"
gem "rake"
gem "rdoc"
gem "ronn" unless RubyVersion.rbx? || RubyVersion.jruby?
gem "ruby-prof" unless RubyVersion.rbx? || RubyVersion.jruby?

group :test do
  gem "simplecov"
  gem "codeclimate-test-reporter", "~> 1.0.0"
end
