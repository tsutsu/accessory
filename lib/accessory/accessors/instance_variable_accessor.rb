require 'accessory/accessor'

##
# Traverses into a named instance-variable of an arbitrary object.
#
# For example, given <tt>InstanceVariableAccessor.new(:foo)</tt>, the
# instance-variable <tt>@foo</tt> of the input data will be traversed.
#
# *Aliases*
# * {Access.ivar}
# * {Access::FluentHelpers#ivar} (included in {Lens} and {BoundLens})
#
# <b>Default constructor</b> used by predecessor accessor
#
# * +Object.new+

class Accessory::Accessors::InstanceVariableAccessor < Accessory::Accessor
  # @param ivar_name [Symbol] the instance-variable name
  # @param default [Object] the default to use if the predecessor accessor passes +nil+ data
  def initialize(ivar_name, default: nil)
    super(default)

    ivar_name = ivar_name.to_s
    ivar_name = "@#{ivar_name}" unless ivar_name.to_s.start_with?("@")
    ivar_name = ivar_name.intern

    @ivar_name = ivar_name
  end

  # @!visibility private
  def inspect_args
    @ivar_name.to_s
  end

  # @!visibility private
  def ensure_valid(traversal_result)
    traversal_result || Object.new
  end

  # @!visibility private
  def traverse(data)
    data.instance_variable_get(@ivar_name)
  end

  # Finds <tt>data.instance_variable_get(:"@#{ivar_name}")</tt>, feeds it
  # down the accessor chain, and returns the result.
  # @param data [Object] the object to traverse
  # @return [Object] the value derived from the rest of the accessor chain
  def get(data)
    value = traverse_or_default(data)

    if block_given?
      yield(value)
    else
      value
    end
  end

  # Finds <tt>data.instance_variable_get(:"@#{ivar_name}")</tt>, feeds it down
  # the accessor chain, and uses
  # <tt>data.instance_variable_set(:"@#{ivar_name}")</tt> to overwrite the
  # stored value with the returned result.
  #
  # If +:pop+ is returned from the accessor chain, the stored value will be
  # removed using <tt>data.remove_instance_variable(:"@#{ivar_name}")</tt>.
  #
  # @param data [Object] the object to traverse
  # @return [Array] a two-element array containing 1. the original value found; and 2. the result value from the accessor chain
  def get_and_update(data)
    value = traverse_or_default(data)

    case yield(value)
    in [result, new_value]
      data.instance_variable_set(@ivar_name, new_value)
      [result, data]
    in :pop
      data.remove_instance_variable(@ivar_name)
      [value, data]
    end
  end
end
