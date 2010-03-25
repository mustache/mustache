require 'cgi'

require 'mustache/parser'
require 'mustache/generator'

class Mustache
  # A Template is a compiled version of a Mustache template.
  #
  # The idea is this: when handed a Mustache template, convert it into
  # a Ruby string by transforming Mustache tags into interpolated
  # Ruby.
  #
  # You shouldn't use this class directly.
  class Template
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
      exp = Parser.new.compile(src)
      Generator.new.compile(exp)
    end
    alias_method :to_s, :compile
  end
end
