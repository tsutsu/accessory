require 'accessory/accessor'

##
# Traverses all elements of an +Enumerable+.
#
# *Aliases*
# * {Access.all}
# * {Access::FluentHelpers#all} (included in {Lens} and {BoundLens})
#
# *Equivalents* in Elixir's {https://hexdocs.pm/elixir/Access.html +Access+} module
# * {https://hexdocs.pm/elixir/Access.html#all/0 +Access.all/0+}
# * {https://hexdocs.pm/elixir/Access.html#key/2 +Access.key/2+}
#
# <b>Default constructor</b> used by predecessor accessor
#
# * +Array.new+

class Accessory::Accessors::AllAccessor < Accessory::Accessor
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

  # Feeds each element of +data+ down the accessor chain, and returns
  # the results.
  # @param data [Enumerable] the +Enumerable+ to iterate through
  # @return [Array] the values derived from the rest of the accessor chain
  def get(data, &succ)
    if succ
      (data || []).map(&succ)
    else
      data
    end
  end

  # Feeds each element of +data+ down the accessor chain, overwriting
  # +data+ with the results.
  #
  # If +:pop+ is returned from the accessor chain, the element is dropped
  # from the new +data+.
  # @param data [Enumerable] the +Enumerable+ to iterate through
  # @return [Array] a two-element array containing 1. the original values found during iteration; and 2. the new +data+
  def get_and_update(data)
    results = []
    new_data = []
    dirty = false

    (data || []).each do |pos|
      case yield(pos)
      in [:clean, result, _]
        results.push(result)
        new_data.push(pos)
        # ok
      in [:dirty, result, new_value]
        results.push(result)
        new_data.push(new_value)
        dirty = true
      in :pop
        results.push(pos)
        dirty = true
      end
    end

    if dirty
      [:dirty, results, new_data]
    else
      [:clean, results, data]
    end
  end
end
