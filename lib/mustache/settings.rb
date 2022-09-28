# Settings which can be configured for all view classes, a single
# view class, or a single Mustache instance.
class Mustache

  def initialize_settings
    @template = nil
    @template_path = nil
    @template_extension = nil
    @template_name = nil
    @template_file = nil
    @raise_on_context_miss = nil
  end

  def self.initialize_settings
    @template = nil
    @template_path = nil
    @template_extension = nil
    @template_name = nil
    @template_file = nil
    @raise_on_context_miss = nil
  end

  initialize_settings

  def self.inherited(subclass)
    subclass.initialize_settings
  end

  #
  # Template Path
  #

  # The template path informs your Mustache view where to look for its
  # corresponding template. It is an array of paths, by default containing
  # one entry:  the current directory (".")
  # When setting up from a string, use path delimiters to create a search path
  # When the template_file is requested, a search is done to find the file in the
  # path, this is then stored as the name.
  #
  # A class named Stat with a template_path of "app/templates" will look
  # for "app/templates/stat.mustache"

  def self.setup_path path
    path = path.split(File::PATH_SEPARATOR) if path.is_a? String
    path.map{|p| File.expand_path(p)}
  end

  def self.template_path
    @template_path ||= setup_path(inheritable_config_for(:template_path, '.'))
  end

  def self.template_path=(path)
    @template_path = setup_path(path)
    @template = nil
  end

  def template_path
    @template_path ||= self.class.template_path
  end

  alias_method :path, :template_path

  def template_path=(path)
    @template_path = self.class.setup_path(path)
    @template = nil
  end

  class << self
    alias_method :path, :template_path
    alias_method :path=, :template_path=
  end


  #
  # Template Extension
  #

  # A Mustache template's default extension is 'mustache', but this can be changed.

  def self.template_extension
    @template_extension ||= inheritable_config_for :template_extension, 'mustache'
  end

  def self.template_extension=(template_extension)
    @template_extension = template_extension
    @template = nil
  end

  def template_extension
    @template_extension ||= self.class.template_extension
  end

  def template_extension=(template_extension)
    @template_extension = template_extension
    @template = nil
  end


  #
  # Template Name
  #

  # The template name is the Mustache template file without any
  # extension or other information. Defaults to `class_name`.
  #
  # You may want to change this if your class is named Stat but you want
  # to re-use another template.
  #
  #   class Stat
  #     self.template_name = "graphs" # use graphs.mustache
  #   end

  def self.template_name
    @template_name || underscore
  end

  def self.template_name=(template_name)
    @template_name = template_name
    @template = nil
  end

  def template_name
    @template_name ||= self.class.template_name
  end

  def template_name=(template_name)
    @template_name = template_name
    @template = nil
  end


  #
  # Template File
  #

  # The template file is the absolute path of the file Mustache will use as its template.
  # By default it's ./class_name.mustache
  #

  def self.template_file
    @template_file || path.map{|p| "#{p}/#{template_name}.#{template_extension}" }.find{|tf| File.readable? tf}
  end

  def self.template_file=(tf)
    @template_file = tf
    @template = nil
  end

  def template_file
    @template_file || path.map{|p| "#{p}/#{template_name}.#{template_extension}" }.find{|tf| File.readable? tf}
  end

  def template_file=(tf)
    @template_file = tf
    @template = nil
  end


  #
  # Template
  #

  # The template is the actual string Mustache uses as its template.
  # There is a bit of magic here: what we get back is actually a
  # Mustache::Template object, but you can still safely use `template=`
  #  with a string.

  def self.template
    @template ||= templateify(File.read(template_file))
  end

  def self.template=(template)
    @template = templateify(template)
  end

  # The template can be set at the instance level.
  def template
    return @template if @template

    # If they sent any instance-level options use that instead of the class's.
    if @template_path || @template_extension || @template_name || @template_file
      @template = templateify(File.read(template_file))
    else
      @template = self.class.template
    end
  end

  def template=(template)
    @template = templateify(template)
  end


  #
  # Raise on context miss
  #

  # Should an exception be raised when we cannot find a corresponding method
  # or key in the current context? By default this is false to emulate ctemplate's
  # behavior, but it may be useful to enable when debugging or developing.
  #
  # If set to true and there is a context miss, `Mustache::ContextMiss` will
  # be raised.

  def self.raise_on_context_miss?
    @raise_on_context_miss
  end

  def self.raise_on_context_miss=(boolean)
    @raise_on_context_miss = boolean
  end

  # Instance level version of `Mustache.raise_on_context_miss?`
  def raise_on_context_miss?
    self.class.raise_on_context_miss? || @raise_on_context_miss
  end

  def raise_on_context_miss=(boolean)
    @raise_on_context_miss = boolean
  end


  #
  # View Namespace
  #

  # The constant under which Mustache will look for views when autoloading.
  # By default the view namespace is `Object`, but it might be nice to set
  # it to something like `Hurl::Views` if your app's main namespace is `Hurl`.

  def self.view_namespace
    @view_namespace ||= inheritable_config_for(:view_namespace, Object)
  end

  def self.view_namespace=(namespace)
    @view_namespace = namespace
  end


  #
  # View Path
  #

  # Mustache searches the view path for .rb files to require when asked to find a
  # view class. Defaults to "."

  def self.view_path
    @view_path ||= inheritable_config_for(:view_path, '.')
  end

  def self.view_path=(path)
    @view_path = path
  end
end
