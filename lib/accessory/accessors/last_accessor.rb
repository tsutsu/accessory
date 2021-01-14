require 'accessory/accessor'

##
# Traverses into the "last" element within an +Enumerable+, using
# <tt>#last</tt>.
#
# This accessor can be preferable to {Accessors::SubscriptAccessor} for objects
# that are not subscriptable, e.g. +Range+.
#
# *Aliases*
# * {Access.last}
# * {Access::FluentHelpers#last} (included in {Lens} and {BoundLens})
#
# <b>Default constructor</b> used by predecessor accessor
#
# * +Array.new+

class Accessory::Accessors::LastAccessor < Accessory::Accessor
  # @!visibility private
  def ensure_valid(traversal_result)
    if traversal_result.kind_of?(Enumerable)
      traversal_result
    else
      []
    end
  end

  # @!visibility private
  def inspect_args; nil; end

  # @!visibility private
  def traverse(data)
    data.last
  end

  # Feeds <tt>data.last</tt> down the accessor chain, returning the result.
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

  # Finds <tt>data.last</tt>, feeds it down the accessor chain, and overwrites
  # the stored value with the returned result.
  #
  # If +:pop+ is returned from the accessor chain, the stored value will be
  # removed using <tt>data.delete_at(-1)</tt>.
  #
  # @param data [Object] the object to traverse
  # @return [Array] a two-element array containing 1. the original value found; and 2. the result value from the accessor chain
  def get_and_update(data)
    old_value = traverse_or_default(data)

    case yield(old_value)
    in [:clean, result, _]
      [:clean, result, data]
    in [:dirty, result, new_value]
      if data.respond_to?(:"last=")
        data.last = new_value
      else
        data[-1] = new_value
      end
      [:dirty, result, data]
    in :pop
      data.delete_at(-1)
      [:dirty, old_value, data]
    end
  end
end
