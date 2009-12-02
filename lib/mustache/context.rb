class Mustache
  # A ContextMiss is raised whenever a tag's target can not be found
  # in the current context if `Mustache#raise_on_context_miss?` is
  # set to true.
  #
  # For example, if your View class does not respond to `music` but
  # your template contains a `{{music}}` tag this exception will be raised.
  #
  # By default it is not raised. See Mustache.raise_on_context_miss.
  class ContextMiss < RuntimeError;  end

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
      elsif @mustache.raise_on_context_miss?
        raise ContextMiss.new("Can't find #{name} in #{@mustache.inspect}")
      else
        nil
      end
    end
  end
end
