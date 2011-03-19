class Stache18n
  @@tags = {
    'comment-and-close' => 'Comment and close',
    'github' => 'GitHub',
    'social-coding' => 'Social Coding'
  }

  def self.t
    @@tags
  end
end

puts Mustache.render(<<END, Stache18n)
<title>{{t.github}} - {{t.social-coding}}</title>
END
