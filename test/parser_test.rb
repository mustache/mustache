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

  def test_parser_errors
    bad_templates = [
      # Template             # Error line/column
      ["{{ Hello World }}",  1, 9 ], # Space
      ["{{ Hello\"World }}", 1, 8 ], # Quote
      ["{{ <elloWorld }}",   1, 3 ], # Bad leading character
      ["{{\n <elloWorld }}", 2, 1 ]  # Bad leading character after \n
    ]

    lexer = Mustache::Parser.new
    bad_templates.each do |template, line, column|
      exception = assert_raise Mustache::Parser::SyntaxError do
        lexer.compile(template)
      end

      output = exception.to_s
      assert_match /Line #{line}/, output
      assert_match /^\s{#{column + 3}}\^/, output
    end
  end

end
