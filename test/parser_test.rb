$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ParserTest < Test::Unit::TestCase
  def test_parser
    lexer = Mustache::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{header}}</h1>
{{#items}}
{{#first}}
  <li><strong>{{name}}</strong></li>
{{/first}}
{{#link}}
  <li><a href="{{url}}">{{name}}</a></li>
{{/link}}
{{/items}}

{{#empty}}
<p>The list is empty.</p>
{{/empty}}
EOF

    expected = [:multi,
      [:static, "<h1>"],
      [:mustache, :etag, "header"],
      [:static, "</h1>\n"],
      [:mustache,
        :section,
        "items",
        [:multi,
          [:mustache,
            :section,
            "first",
            [:multi,
              [:static, "<li><strong>"],
              [:mustache, :etag, "name"],
              [:static, "</strong></li>\n"]]],
          [:mustache,
            :section,
            "link",
            [:multi,
              [:static, "<li><a href=\""],
              [:mustache, :etag, "url"],
              [:static, "\">"],
              [:mustache, :etag, "name"],
              [:static, "</a></li>\n"]]]]],
      [:mustache,
        :section,
        "empty",
        [:multi, [:static, "<p>The list is empty.</p>\n"]]]]

    assert_equal expected, tokens
  end
end
