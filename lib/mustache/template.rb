require 'cgi'

class Mustache
  # A Template is a compiled version of a Mustache template.
  #
  # The idea is this: when handed a Mustache template, convert it into
  # a Ruby string by transforming Mustache tags into interpolated
  # Ruby.
  #
  # You shouldn't use this class directly.
  class Template
    # An UnclosedSection error is thrown when a {{# section }} is not
    # closed.
    #
    # For example:
    #   {{# open }} blah {{/ close }}
    class UnclosedSection < RuntimeError
      attr_reader :message

      # Report the line number of the offending unclosed section.
      def initialize(source, matching_line, unclosed_section)
        num = 0

        source.split("\n").each_with_index do |line, i|
          num = i + 1
          break if line.strip == matching_line.strip
        end

        @message = "line #{num}: ##{unclosed_section.strip} is not closed"
      end
    end

    # Expects a Mustache template as a string along with a template
    # path, which it uses to find partials.
    def initialize(source, template_path = '.', template_extension = 'mustache')
      @source = source
      @template_path = template_path
      @template_extension = template_extension
      @tmpid = 0
    end

    # Renders the `@source` Mustache template using the given
    # `context`, which should be a simple hash keyed with symbols.
    def render(context)
      # Compile our Mustache template into a Ruby string
      compiled = "def render(ctx) #{compile} end"

      # Here we rewrite ourself with the interpolated Ruby version of
      # our Mustache template so subsequent calls are very fast and
      # can skip the compilation stage.
      instance_eval(compiled, __FILE__, __LINE__ - 1)

      # Call the newly rewritten version of #render
      render(context)
    end

    # Does the dirty work of transforming a Mustache template into an
    # interpolation-friendly Ruby string.
    def compile(src = @source)
      "\"#{compile_sections(src)}\""
    end

    # {{#sections}}okay{{/sections}}
    #
    # Sections can return true, false, or an enumerable.
    # If true, the section is displayed.
    # If false, the section is not displayed.
    # If enumerable, the return value is iterated over (a `for` loop).
    def compile_sections(src)
      res = ""
      while src =~ /#{otag}\#([^\}]*)#{ctag}\s*(.+?)#{otag}\/\1#{ctag}\s*/m
        # $` = The string to the left of the last successful match
        res << compile_tags($`)
        name = $1.strip.to_sym.inspect
        code = compile($2)
        ctxtmp = "ctx#{tmpid}"
        res << ev(<<-compiled)
        if v = ctx[#{name}]
          v = [v] if v.is_a?(Hash) # shortcut when passed a single hash
          if v.respond_to?(:each)
            #{ctxtmp} = ctx.dup
            begin
              r = v.map { |h| ctx.update(h); #{code} }.join
            rescue TypeError => e
              raise TypeError,
                "All elements in {{#{name.to_s[1..-1]}}} are not hashes!"
            end
            ctx.replace(#{ctxtmp})
            r
          else
            #{code}
          end
        end
        compiled
        # $' = The string to the right of the last successful match
        src = $'
      end
      res << compile_tags(src)
    end

    # Find and replace all non-section tags.
    # In particular we look for four types of tags:
    # 1. Escaped variable tags - {{var}}
    # 2. Unescaped variable tags - {{{var}}}
    # 3. Comment variable tags - {{! comment}
    # 4. Partial tags - {{> partial_name }}
    def compile_tags(src)
      res = ""
      while src =~ /#{otag}(#|=|!|<|>|\{)?(.+?)\1?#{ctag}+/m
        res << str($`)
        case $1
        when '#'
          # Unclosed section - raise an error and
          # report the line number
          raise UnclosedSection.new(@source, $&, $2)
        when '!'
          # ignore comments
        when '='
          self.otag, self.ctag = $2.strip.split(' ', 2)
        when '>', '<'
          res << compile_partial($2.strip)
        when '{'
          res << utag($2.strip)
        else
          res << etag($2.strip)
        end
        src = $'
      end
      res << str(src)
    end

    # Partials are basically a way to render views from inside other views.
    def compile_partial(name)
      src = File.read("#{@template_path}/#{name}.#{@template_extension}")
      compile(src)[1..-2]
    end

    # Generate a temporary id, used when compiling code.
    def tmpid
      @tmpid += 1
    end

    # Get a (hopefully) literal version of an object, sans quotes
    def str(s)
      s.inspect[1..-2]
    end

    # {{ - opening tag delimiter
    def otag
      @otag ||= Regexp.escape('{{')
    end

    def otag=(tag)
      @otag = Regexp.escape(tag)
    end

    # }} - closing tag delimiter
    def ctag
      @ctag ||= Regexp.escape('}}')
    end

    def ctag=(tag)
      @ctag = Regexp.escape(tag)
    end

    # {{}} - an escaped tag
    def etag(s)
      ev("CGI.escapeHTML(ctx[#{s.strip.to_sym.inspect}].to_s)")
    end

    # {{{}}} - an unescaped tag
    def utag(s)
      ev("ctx[#{s.strip.to_sym.inspect}]")
    end

    # An interpolation-friendly version of a string, for use within a
    # Ruby string.
    def ev(s)
      "#\{#{s}}"
    end
  end
end
