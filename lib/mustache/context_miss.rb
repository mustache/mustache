class Mustache

  # A ContextMiss is raised whenever a tag's target can not be found
  # in the current context if `Mustache#raise_on_context_miss?` is
  # set to true.
  #
  # For example, if your View class does not respond to `music` but
  # your template contains a `{{music}}` tag this exception will be raised.
  #
  # By default it is not raised. See Mustache.raise_on_context_miss.
  #
  class ContextMiss < RuntimeError;  end

  # A ContextLevelViolation is raised whenever accessing a key in the context is
  # not allowed by the selected context access security level
  #
  # For example, if your context access security level is set to 3 but
  # your template tries to access an inherited method this exception will be raised.
  #
  # By default it is only raised for blacklisted keys in objects.
  # See Mustache.context_access_security_level.
  #
  class ContextLevelViolation < ContextMiss;  end

  class Context
    # Raises ContextLevelViolation or returns default depending on raise_on_context_miss
    #
    # @param [String] message The error message if raise_on_context_miss is set
    # @param [Object] default An optional default value, to return if the key is not found.
    #
    # @return [Object] The default value if errors are not raised
    #
    def context_level_violation(message, default = nil)
      return default unless mustache_in_stack.raise_on_context_miss?
      raise ContextLevelViolation.new(message)
    end
  end


  MethodBlacklist = ["allocate", "attached_object", "superclass", "subclasses", "new", "autoload?", "autoload",
  "included_modules", "include?", "set_temporary_name", "ancestors", "attr", "attr_reader", "attr_writer",
  "attr_accessor", "public_instance_method", "instance_methods", "public_instance_methods",
  "protected_instance_methods", "private_instance_methods", "undefined_instance_methods", "freeze", "const_get",
  "constants", "const_missing", "const_defined?", "const_set", "const_source_location", "remove_class_variable",
  "class_variable_get", "class_variables", "private_constant", "class_variable_set", "class_variable_defined?",
  "public_constant", "include", "deprecate_constant", "singleton_class?", "prepend", "refinements", "define_method",
  "module_exec", "class_exec", "module_eval", "class_eval", "remove_method", "undef_method", "alias_method",
  "method_defined?", "public_method_defined?", "private_method_defined?", "protected_method_defined?",
  "public_class_method", "private_class_method", "instance_method", "singleton_class", "dup", "itself", "methods",
  "singleton_methods", "protected_methods", "private_methods", "public_methods", "instance_variables",
  "instance_variable_get", "instance_variable_set", "instance_variable_defined?", "remove_instance_variable",
  "instance_of?", "kind_of?", "is_a?", "display", "public_send", "extend", "clone", "class", "frozen?", "tap",
  "then", "yield_self", "respond_to?", "method", "public_method", "singleton_method", "define_singleton_method",
  "hash", "object_id", "send", "enum_for", "__send__", "instance_eval", "instance_exec", "__id__"]
end
