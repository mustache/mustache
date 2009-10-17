class Mustache
  # A Context represents the context which a Mustache template is
  # executed within. All Mustache tags reference keys in the Context.
  class Context < Hash
    def initialize(mustache)
      @mustache = mustache
      super()
    end

    def [](name)
      if has_key?(name)
        super
      elsif has_key?(name.to_s)
        super(name.to_s)
      elsif @mustache.respond_to?(name)
        @mustache.send(name)
      else
        raise "Can't find #{name} in #{@mustache.inspect}"
      end
    end
  end
end
