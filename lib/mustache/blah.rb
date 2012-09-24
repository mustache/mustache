require 'mustache'

class Mustache::Template
  def token_names
    def recursor(toks, section)
      toks.map do |token|
        next unless token.is_a? Array
        if token[0] == :mustache && [:etag,:utag].include? token[1]
          (section + [token[2][2][0]]).join '.'
        elsif token[0] == :mustache && [:section,:inverted_section].include? token[1]
          recursor(token[4], section + [token[2][2][0]])
        else
          recursor(token, section)
        end
      end
    end
    recursor(tokens, []).flatten.reject(&:nil?).uniq
  end

  def section_names
    def recursor(toks, section)
      sections = []
      toks.each do |token|
        next unless token.is_a? Array
        if token[0] == :mustache && [:section,:inverted_section].include? token[1]
          new_section = section + [token[2][2][0]]
          sections += [ new_section.join('.') ] + recursor(token[4], new_section)
        else
          sections += recursor(token, section)
        end
      end
      sections
    end
    recursor(tokens,[]).reject(&:nil?).uniq
  end

  def partial_names
    def recursor(toks)
      partials = []
      toks.each do |token|
        next unless token.is_a? Array
        partials += if token[0..1] == [:mustache, :partial]
          [token[2]] # partial here
        else
          recursor(token)
        end
      end
      partials
    end
    recursor(tokens).reject(&:nil?).uniq
  end

end

if __FILE__ == $0
  require "test/unit"

  class TestMustacheTokenNames < Test::Unit::TestCase

    def setup
      @template = Mustache::Template.new(@@template_text ||= DATA.read)
    end

    def test_token_names
      assert_equal(@template.token_names,
        [ "yourname",
          "HOME",
          "friend.name",
          "friend.morr.word",
          "friend.morr.up",
          "friend.morr.awesomesauce",
          "friend.morr.hiss",
          "friend.notinmorr",
          "friend.person",
          "love",
          "triplestash"
        ]
      )
    end

    def test_partial_names
      assert_equal(@template.partial_names, ["partial1", "partial2"])
    end

    def test_section_names
      assert_equal(@template.section_names, ["friend", "friend.morr"])
    end
  end
end

__END__
Hi there {{yourname}}.  Your home directory is {{HOME}}.

{{#friend}}
Your friend is named {{name}}
  {{#morr}}
   Hey {{word}} {{up}} {{{awesomesauce}}}.
   {{/morr}}
   {{^morr}}
   Booooo.  {{hiss}}
   {{/morr}}
   {{notinmorr}}
   {{> partial1}}
{{/friend}}
{{^friend}}
You have no friends, {{person}}.  You suck.
{{/friend}}

{{> partial2}}
{{! comments are awesome }}

{{={% %}=}}

{%love%}
{%={{ }}=%}
{{{triplestash}}}
