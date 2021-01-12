module Accessory; end

require 'accessory/accessor'
require 'accessory/accessors/subscript_accessor'

##
# A LensPath is a "free-floating" lens (i.e. not bound to a subject document.)
# It serves as a container for {Accessor} instances, and represents the
# traversal path one would take to get from a hypothetical subject document,
# to a data value nested somewhere within it.
#
# A LensPath can be used directly to traverse documents, using {get_in},
# {put_in}, {pop_in}, etc. These methods take an explicit subject document to
# traverse, rather than requiring that the LensPath be bound to a document
# first.
#
# As such, a LensPath is reusable. A common use of a LensPath is to access the
# same deeply-nested traversal position within a large collection of subject
# documents, e.g.:
#
#    foo_bar_baz = LensPath[:foo, :bar, :baz]
#    docs.map{ |doc| foo_bar_baz.get_in(doc) }
#
# A LensPath can also be bound to a specific subject document to create a
# {Lens}. See {Lens.on}.
#
# LensPaths are created frozen. Methods that "extend" a LensPath actually
# create and return new derived LensPaths.

class Accessory::LensPath
  # Returns the empty (identity) LensPath.
  # @return [LensPath] the empty (identity) LensPath.
  def self.empty
    @empty_lens_path ||= (new([]).freeze)
  end

  # Returns a {LensPath} containing the specified +accessors+.
  # @return [LensPath] a LensPath containing the specified +accessors+.
  def self.[](*accessors)
    new(accessors).freeze
  end

  class << self
    private :new
  end

  # @!visibility private
  def initialize(initial_parts)
    @parts = []

    for part in initial_parts
      append_accessor!(part)
    end
  end

  # @!visibility private
  def to_a
    @parts
  end

  # @!visibility private
  def inspect(format: :long)
    parts_desc = @parts.map{ |part| part.inspect(format: :short) }.join(', ')
    parts_desc = "[#{parts_desc}]"

    case format
    when :long
      "#LensPath#{parts_desc}"
    when :short
      parts_desc
    end
  end

  # Returns a new {LensPath} resulting from appending +accessor+ to the receiver.
  # @param accessor [Object] the accessor to append
  # @return [LensPath] the new joined LensPath
  def then(accessor)
    d = self.dup
    d.instance_eval do
      @parts = @parts.dup
      append_accessor!(accessor)
    end
    d.freeze
  end

  # Returns a new {LensPath} resulting from concatenating +other+ to the end
  # of the receiver.
  # @param other [Object] an accessor, an +Array+ of accessors, or another LensPath
  # @return [LensPath] the new joined LensPath
  def +(other)
    parts =
      case other
      when Accessory::LensPath
        other.to_a
      when Array
        other
      else
        [other]
      end

    d = self.dup
    d.instance_eval do
      for part in parts
        append_accessor!(part)
      end
    end
    d.freeze
  end

  alias_method :/, :+

  # Traverses +subject+ using the chain of accessors held in this LensPath,
  # returning the discovered value.
  #
  # *Equivalent* in Elixir:  {https://hexdocs.pm/elixir/Kernel.html#get_in/2 +Kernel.get_in/2+}
  #
  # @return [Object] the value found after all traversals.
  def get_in(subject)
    if @parts.empty?
      subject
    else
      get_in_step(subject, @parts)
    end
  end

  # Traverses +subject+ using the chain of accessors held in this LensPath,
  # modifying the final value at the end of the traversal chain using
  # the passed +mutator_fn+, and returning the original targeted value(s)
  # pre-modification.
  #
  # +mutator_fn+ must return one of two data "shapes":
  # * a two-element +Array+, representing:
  #   1. the value to surface as the "get" value of the traversal
  #   2. the new value to replace at the traversal-position
  # * the Symbol +:pop+ — which will remove the value from its parent, and
  #   return it as-is.
  #
  # *Equivalent* in Elixir: {https://hexdocs.pm/elixir/Kernel.html#get_and_update_in/3 +Kernel.get_and_update_in/3+}
  #
  # @param subject [Object] the data-structure to traverse
  # @param mutator_fn [Proc] a block taking the original value derived from
  #   traversing +subject+, and returning a modification operation.
  # @return [Array] a two-element +Array+, consisting of
  #   1. the _old_ value(s) found after all traversals, and
  #   2. the updated +subject+
  def get_and_update_in(subject, &mutator_fn)
    if @parts.empty?
      subject
    else
      get_and_update_in_step(subject, @parts, mutator_fn)
    end
  end

  # Traverses +subject+ using the chain of accessors held in this LensPath,
  # replacing the final value at the end of the traversal chain with the
  # result from the passed +new_value_fn+.
  #
  # *Equivalent* in Elixir: {https://hexdocs.pm/elixir/Kernel.html#update_in/3 +Kernel.update_in/3+}
  #
  # @param subject [Object] the data-structure to traverse
  # @param new_value_fn [Proc] a block taking the original value derived from
  #   traversing +subject+, and returning a replacement value.
  # @return [Array] a two-element +Array+, consisting of
  #   1. the _old_ value(s) found after all traversals, and
  #   2. the updated +subject+
  def update_in(subject, &new_value_fn)
    _, new_data = self.get_and_update_in(data){ |v| [nil, new_value_fn.call(v)] }
    new_data
  end

  # Traverses +subject+ using the chain of accessors held in this LensPath,
  # replacing the final value at the end of the traversal chain with
  # +new_value+.
  #
  # *Equivalent* in Elixir: {https://hexdocs.pm/elixir/Kernel.html#put_in/3 +Kernel.put_in/3+}
  #
  # @param subject [Object] the data-structure to traverse
  # @param new_value [Object] a replacement value at the traversal position.
  # @return [Object] the updated +subject+
  def put_in(subject, new_value)
    _, new_data = self.get_and_update_in(subject){ [nil, new_value] }
    new_data
  end

  # Traverses +subject+ using the chain of accessors held in this LensPath,
  # removing the final value at the end of the traversal chain from its position
  # within its parent container.
  #
  # *Equivalent* in Elixir: {https://hexdocs.pm/elixir/Kernel.html#pop_in/2 +Kernel.pop_in/2+}
  #
  # @param subject [Object] the data-structure to traverse
  # @return [Object] the updated +subject+
  def pop_in(subject)
    self.get_and_update_in(subject){ :pop }
  end

  def append_accessor!(part)
    accessor =
      case part
      when Accessory::Accessor
        part
      when Array
        Accessory::SubscriptAccessor.new(part[0], default: part[1])
      else
        Accessory::SubscriptAccessor.new(part)
      end

    unless @parts.empty?
      @parts.last.succ_default_data_constructor = accessor.default_data_constructor
    end

    @parts.push(accessor)
  end
  private :append_accessor!

  def get_in_step(data, path)
    step_accessor = path.first
    rest_of_path = path[1..-1]

    if rest_of_path.empty?
      step_accessor.get(data)
    else
      step_accessor.get(data){ |v| get_in_step(v, rest_of_path) }
    end
  end
  private :get_in_step

  def get_and_update_in_step(data, path, mutator_fn)
    step_accessor = path.first
    rest_of_path = path[1..-1]

    if rest_of_path.empty?
      step_accessor.get_and_update(data, &mutator_fn)
    else
      step_accessor.get_and_update(data){ |v| get_and_update_in_step(v, rest_of_path, mutator_fn) }
    end
  end
  private :get_and_update_in_step
end
