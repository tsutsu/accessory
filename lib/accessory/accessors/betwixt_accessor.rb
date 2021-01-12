require 'accessory/accessor'
require 'accessory/traversal_position/enumerable_before_offset'

##
# Traverses into a specified cursor-position "between" two elements of an
# +Enumerable+, including the positions at the "edges" (i.e. before the first,
# or after the last.)
#
# If the provided +offset+ is positive, this accessor will traverse the position
# between <tt>offset - 1</tt>  and +offset+; if +offset+ is negative, this accessor
# will traverse the position _after_ +offset+.
#
# The +offset+ in this accessor has equivalent semantics to the offset in
# <tt>Array#insert(offset, obj)</tt>.
#
# {BetwixtAccessor} can be used with {Lens#put_in} to insert new
# elements into an Enumerable between the existing ones. If you want to extend
# an +Enumerable+ as you would with <tt>#push</tt> or <tt>#unshift</tt>, this
# accessor will have better behavior than using {SubscriptAccessor} would.
#
# *Aliases*
# * {Access.betwixt}
# * {Access::FluentHelpers#betwixt} (included in {Lens} and {BoundLens})
#
# <b>Default constructor</b> used by predecessor accessor
#
# * +Array.new+

class Accessory::BetwixtAccessor < Accessory::Accessor
  # @param offset [Integer] the cursor position (i.e. the index of the element after the cursor)
  # @param default [Object] the default to use if the predecessor accessor passes +nil+ data
  def initialize(offset, default: nil)
    super(default)
    @offset = offset
  end

  # @!visibility private
  def inspect_args
    @offset.inspect
  end

  # @!visibility private
  def default_data_constructor
    lambda{ Array.new }
  end

  # @!visibility private
  def traverse(data)
    data_len = data.length

    Accessory::TraversalPosition::EnumerableBeforeOffset.new(
      @offset,
      (@offset > 0) ? data[@offset - 1] : nil,
      (@offset < (data_len - 1)) ? data[@offset + 1] : nil,
      is_first: @offset == 0,
      is_last: @offset == data_len
    )
  end

  # Feeds a {TraversalPosition::EnumerableBeforeOffset} representing the
  # position between the elements of +data+ at +@offset+ down the accessor
  # chain.
  #
  # @param data [Enumerable] the +Enumerable+ to traverse into
  # @return [Array] the generated {TraversalPosition::EnumerableBeforeOffset}
  def get(data)
    pos = value_or_default(data || [])

    if block_given?
      yield(pos)
    else
      pos
    end
  end

  # Feeds a {TraversalPosition::EnumerableBeforeOffset} representing the
  # position between the elements of +data+ at +@offset+ down the accessor
  # chain, manipulating +data+ using the result.
  #
  # If a new element is returned up the accessor chain, the element is inserted
  # at the specified position, using <tt>data.insert(@offset, e)</tt>.
  #
  # If +:pop+ is returned up the accessor chain, no new element is added.
  #
  # @param data [Enumerable] the +Enumerable+ to traverse into
  # @return [Array] a two-element array containing
  #   1. the generated {TraversalPosition::EnumerableBeforeOffset}
  #   2. the new {data}
  def get_and_update(data)
    pos = value_or_default(data || [])

    case yield(pos)
    in [result, new_value]
      data ||= []
      data.insert(@offset, new_value)
      [result, data]
    in :pop
      [nil, data]
    end
  end
end
