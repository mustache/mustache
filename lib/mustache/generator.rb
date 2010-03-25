class Mustache
  class Generator
    def initialize(options = {})
      @options = options
    end

    def compile(exp)
      "\"#{compile!(exp)}\""
    end

    def compile!(exp)
      case exp.first
      when :multi
        exp[1..-1].map { |e| compile!(e) }.join
      when :static
        str(exp[1])
      when :mustache
        send("on_#{exp[1]}", *exp[2..-1])
      else
        raise "Unhandled exp: #{exp.first}"
      end
    end

    def on_section(name, content)
      code = compile(content)
      ev(<<-compiled)
      if v = ctx[#{name.to_sym.inspect}]
        if v == true
          #{code}
        else
          v = [v] unless v.is_a?(Array) # shortcut when passed non-array
          v.map { |h| ctx.push(h); r = #{code}; ctx.pop; r }.join
        end
      end
      compiled
    end

    def on_partial(name)
      ev("ctx.partial(#{name.to_sym.inspect})")
    end

    def on_utag(name)
      ev("ctx[#{name.to_sym.inspect}]")
    end

    def on_etag(name)
      ev("CGI.escapeHTML(ctx[#{name.to_sym.inspect}].to_s)")
    end

    # An interpolation-friendly version of a string, for use within a
    # Ruby string.
    def ev(s)
      "#\{#{s}}"
    end

    def str(s)
      s.inspect[1..-2]
    end
  end
end
