require 'accessory/accessor'

##
# Traverses an abstract "attribute" of an arbitrary object, represented by a
# named getter/setter method pair.
#
# For example, <tt>AttributeAccessor.new(:foo)</tt> will traverse through
# the getter/setter pair <tt>.foo</tt> and <tt>.foo=</tt>.
#
# The abstract "attribute" does not have to correspond to an actual
# +attr_accessor+; the {AttributeAccessor} will work as long as the relevant
# named getter/setter methods exist on the receiver.
#
# *Aliases*
# * {Access.attr}
# * {Access::FluentHelpers#attr} (included in {LensPath} and {Lens})
#
# <b>Default constructor</b> used by predecessor accessor
#
# * +OpenStruct.new+

class Accessory::AttributeAccessor < Accessory::Accessor
  # @param attr_name [Symbol] the attribute name (i.e. name of the getter method)
  # @param default [Object] the default to use if the predecessor accessor passes +nil+ data
  def initialize(attr_name, default: nil)
    super(default)
    @getter_method_name = :"#{attr_name}"
    @setter_method_name = :"#{attr_name}="
  end

  # @!visibility private
  def name; "attr"; end

  # @!visibility private
  def inspect_args
    @getter_method_name.inspect
  end

  # @!visibility private
  def inspect(format: :long)
    case format
    when :long
      super()
    when :short
      ".#{@getter_method_name}"
    end
  end

  # @!visibility private
  def default_fn_for_previous_step
    lambda do
      require 'ostruct'
      OpenStruct.new
    end
  end

  # @!visibility private
  def value_from(data)
    data.send(@getter_method_name)
  end

  # Finds <tt>data.send(:"#{attr_name}")</tt>, feeds it down the accessor chain,
  # and returns the result.
  # @param data [Object] the object to traverse
  # @return [Object] the value derived from the rest of the accessor chain
  def get(data)
    value = value_or_default(data)

    if block_given?
      yield(value)
    else
      value
    end
  end

  # Finds <tt>data.send(:"#{attr_name}")</tt>, feeds it down the accessor chain,
  # and uses <tt>data.send(:"#{attr_name}=")</tt> to overwrite the stored value
  # with the returned result.
  #
  # If +:pop+ is returned from the accessor chain, the stored value will be
  # overwritten with `nil`.
  #
  # @param data [Object] the object to traverse
  # @return [Array] a two-element array containing 1. the original value found; and 2. the result value from the accessor chain
  def get_and_update(data)
    value = value_or_default(data)

    case yield(value)
    in [result, new_value]
      data.send(@setter_method_name, new_value)
      [result, data]
    in :pop
      data.send(@setter_method_name, nil)
      [value, data]
    end
  end
end
