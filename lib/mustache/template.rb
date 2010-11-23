require 'cgi'

require 'mustache/parser'
require 'mustache/generator'

class Mustache
  # A Template represents a Mustache template. It compiles and caches
  # a raw string template into something usable.
  #
  # The idea is this: when handed a Mustache template, convert it into
  # a Ruby string by transforming Mustache tags into interpolated
  # Ruby.
  #
  # You shouldn't use this class directly, instead:
  #
  # >> Mustache.render(template, hash)
  class Template
    attr_reader :source

    # Expects a Mustache template as a string along with a template
    # path, which it uses to find partials.
    def initialize(source)
      @source = source
    end

    # Renders the `@source` Mustache template using the given
    # `context`, which should be a simple hash keyed with symbols.
    #
    # The first time a template is rendered, this method is overriden
    # and from then on it is "compiled". Subsequent calls will skip
    # the compilation step and run the Ruby version of the template
    # directly.
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
      Generator.new.compile(tokens(src))
    end
    alias_method :to_s, :compile

    # Returns an array of tokens for a given template.
    def tokens(src = @source)
      Parser.new.compile(src)
    end
  end
end
