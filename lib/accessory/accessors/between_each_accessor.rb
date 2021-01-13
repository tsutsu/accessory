require 'accessory/accessor'
require 'accessory/traversal_position/enumerable_before_offset'

##
# Traverses the positions "between" the elements of an +Enumerable+, including
# the positions at the "edges" (i.e. before the first, and after the last.)
#
# {BetweenEachAccessor} can be used with {Lens#put_in} to insert new
# elements into an Enumerable between the existing ones.
#
# *Aliases*
# * {Access.between_each}
# * {Access::FluentHelpers#between_each} (included in {Lens} and {BoundLens})
#
# <b>Default constructor</b> used by predecessor accessor
#
# * +Array.new+

class Accessory::Accessors::BetweenEachAccessor < Accessory::Accessor
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
    data_len = data.length

    positions = [
      (0..data_len).to_a,
      data + [nil],
      [nil] + data
    ]

    positions.transpose.map do |(i, b, a)|
      Accessory::TraversalPosition::EnumerableBeforeOffset.new(i, b, a, is_first: i == 0, is_last: i == data_len)
    end
  end

  # Feeds {TraversalPosition::EnumerableBeforeOffset}s representing the
  # positions between the elements of +data+ down the accessor chain.
  #
  # @param data [Enumerable] the +Enumerable+ to iterate through
  # @return [Array] the generated {TraversalPosition::EnumerableBeforeOffset}s
  def get(data)
    positions = traverse_or_default(data || [])

    if block_given?
      positions.map{ |rec| yield(rec) }
    else
      positions
    end
  end

  # Feeds {TraversalPosition::EnumerableBeforeOffset}s representing the
  # positions between the elements of +data+ down the accessor chain,
  # manipulating +data+ using the results.
  #
  # If a new element is returned up the accessor chain, the element is inserted
  # between the existing elements.
  #
  # If +:pop+ is returned up the accessor chain, no new element is added.
  #
  # @param data [Enumerable] the +Enumerable+ to iterate through
  # @return [Array] a two-element array containing
  #   1. the {TraversalPosition::EnumerableBeforeOffset}s
  #   2. the new {data}
  def get_and_update(data)
    results = []
    new_data = []

    positions = traverse_or_default(data || [])

    positions.each do |pos|
      case yield(pos)
      in [result, new_value]
        new_data.push(new_value)
        results.push(result)
      in :pop
      end

      unless pos.last?
        new_data.push(pos.elem_after)
      end
    end

    [results, new_data]
  end
end
