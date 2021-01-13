require 'accessory/accessor'

##
# Traverses into the "first" element within an +Enumerable+, using
# <tt>#first</tt>.
#
# This accessor can be preferable to {SubscriptAccessor} for objects that
# are not subscriptable, e.g. {Range}.
#
# *Aliases*
# * {Access.first}
# * {Access::FluentHelpers#first} (included in {Lens} and {BoundLens})
#
# <b>Default constructor</b> used by predecessor accessor
#
# * +Array.new+

class Accessory::Accessors::FirstAccessor < Accessory::Accessor
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
    data.first
  end

  # Feeds <tt>data.first</tt> down the accessor chain, returning the result.
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

  # Finds <tt>data.first</tt>, feeds it down the accessor chain, and overwrites
  # the stored value with the returned result.
  #
  # If +:pop+ is returned from the accessor chain, the stored value will be
  # removed using <tt>data.delete_at(0)</tt>.
  #
  # @param data [Object] the object to traverse
  # @return [Array] a two-element array containing 1. the original value found; and 2. the result value from the accessor chain
  def get_and_update(data)
    old_value = traverse_or_default(data)

    case yield(old_value)
    in [result, new_value]
      if data.respond_to?(:"first=")
        data.first = new_value
      else
        data[0] = new_value
      end
      [result, data]
    in :pop
      data.delete_at(0)
      [old_value, data]
    end
  end
end
