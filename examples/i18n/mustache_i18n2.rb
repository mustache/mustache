class Stache18n
  @@tags = {
    'comment-and-close' => 'Comment and close',
    'github' => 'GitHub',
    'social-coding' => 'Social Coding'
  }

  def self.t
    new
  end

  def method_missing(tag)
    @@tags[tag.to_s]
  end

  def respond_to?(tag)
    @@tags[tag.to_s]
  end
end

puts Mustache.render(<<END, Stache18n)
<title>{{t.github}} - {{t.social-coding}}</title>
END
