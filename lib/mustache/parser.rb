require 'strscan'

class Mustache
  class Parser
    class SyntaxError < StandardError
      def initialize(message, position)
        @message = message
        @lineno, @column, @line = position
        @stripped_line = @line.strip
        @stripped_column = @column - (@line.size - @line.lstrip.size)
      end

      def to_s
        <<-EOF
#{@message}
  Line #{@lineno}
    #{@stripped_line}
    #{' ' * @stripped_column}^
EOF
      end
    end

    # After these types of tags, all whitespace will be skipped.
    SKIP_WHITESPACE = [ '#', '/' ]

    # The content allowed in a tag name.
    ALLOWED_CONTENT = /(\w|-)*/

    # These types of tags allow any content,
    # the rest only allow ALLOWED_CONTENT.
    ANY_CONTENT = [ '!', '=' ]

    attr_reader :scanner, :result
    attr_writer :otag, :ctag

    def initialize(options = {})
      @options = {}
    end

    def regexp(thing)
      /#{Regexp.escape(thing)}/
    end

    def otag
      @otag ||= '{{'
    end

    def ctag
      @ctag ||= '}}'
    end

    def compile(data)
      # Keeps information about opened sections.
      @sections = []
      @result = [:multi]
      @scanner = StringScanner.new(data)

      until @scanner.eos?
        scan_tags || scan_text
      end

      unless @sections.empty?
        # We have parsed the whole file, but there's still opened sections.
        type, pos, result = @sections.pop
        error "Unclosed section #{type.inspect}", pos
      end

      @result
    end

    def scan_tags
      return unless @scanner.scan(regexp(otag))

      # Since {{= rewrites ctag, we store the ctag which should be used
      # when parsing this specific tag.
      current_ctag = self.ctag
      type = @scanner.scan(/#|\/|=|!|<|>|&|\{/)
      @scanner.skip(/\s*/)

      if ANY_CONTENT.include?(type)
        r = /\s*#{regexp(type)}?#{regexp(current_ctag)}/
        content = scan_until_exclusive(r)
      else
        content = @scanner.scan(ALLOWED_CONTENT)
      end

      error "Illegal content in tag" if content.empty?

      case type
      when '#'
        block = [:multi]
        @result << [:mustache, :section, content, block]
        @sections << [content, position, @result]
        @result = block
      when '/'
        section, pos, result = @sections.pop
        @result = result

        if section.nil?
          error "Closing unopened #{content.inspect}"
        elsif section != content
          error "Unclosed section #{section.inspect}", pos
        end
      when '!'
        # ignore comments
      when '='
        self.otag, self.ctag = content.split(' ', 2)
      when '>', '<'
        @result << [:mustache, :partial, content]
      when '{', '&'
        type = "}" if type == "{"
        @result << [:mustache, :utag, content]
      else
        @result << [:mustache, :etag, content]
      end

      @scanner.skip(/\s+/)
      @scanner.skip(regexp(type)) if type

      unless close = @scanner.scan(regexp(current_ctag))
        error "Unclosed tag"
      end

      @scanner.skip(/\s+/) if SKIP_WHITESPACE.include?(type)
    end

    def scan_text
      text = scan_until_exclusive(regexp(otag))

      if text.nil?
        # Couldn't find any otag, which means the rest is just static text.
        text = @scanner.rest
        # Mark as done.
        @scanner.clear
      end

      @result << [:static, text]
    end

    # Scans the string until the pattern is matched. Returns the substring
    # *excluding* the end of the match, advancing the scan pointer to that
    # location. If there is no match, nil is returned.
    def scan_until_exclusive(regexp)
      pos = @scanner.pos
      if @scanner.scan_until(regexp)
        @scanner.pos -= @scanner.matched.size
        @scanner.pre_match[pos..-1]
      end
    end

    # Returns [lineno, column, line]
    def position
      # The rest of the current line
      rest = @scanner.check_until(/\n|\Z/).to_s.chomp

      # What we have parsed so far
      parsed = @scanner.string[0...@scanner.pos]

      lines = parsed.split("\n")

      [ lines.size, lines.last.size - 1, lines.last + rest ]
    end

    def error(message, pos = position)
      raise SyntaxError.new(message, pos)
    end
  end
end
