module Accessory; end
module Accessory::TraversalPosition; end

##
# Represents the empty intervals between and surrounding the elements of an
# +Enumerable#each+ traversal.
#
# Examples to build intuition:
#
# * An +EnumerableBeforeOffset+ with an <tt>.offset</tt> of <tt>0</tt>
#   represents the position directly before the first result from
#   <tt>#each</tt>, i.e. "the beginning." Using {Lens#put_in} at this position
#   will _prepend_ to the +Enumerable+.
#
# * An +EnumerableBeforeOffset+ with an <tt>.offset</tt> equal to the
#   <tt>#length</tt> of the +Enumerable+ (recognizable by
#   <tt>EnumerableBeforeOffset#last?</tt> returning +true+) represents
#   represents the position directly before the end of the enumeration,
#   i.e. "the end" of the +Enumerable+. Using {Lens#put_in} at this position
#   will _append_ to the +Enumerable+.
#
# * In general, using {Lens#put_in} with an +EnumerableBeforeOffset+ with an
#   <tt>.offset</tt> of +n+ will insert an element _between_ elements
#   <tt>n - 1</tt> and +n+ in the enumeration sequence.
#
# * Returning <tt>:pop</tt> from {Lens#get_and_update_in} for an
#   +EnumerableBeforeOffset+-terminated {Lens} will have no effect, as
#   you're removing an empty slice.

class Accessory::TraversalPosition::EnumerableBeforeOffset
  ##
  # @!visibility private
  def initialize(offset, elem_before, elem_after, is_first: false, is_last: false)
    @offset = offset
    @elem_before = elem_before
    @elem_after = elem_after
    @is_first = is_first
    @is_last = is_last
  end

  # @return [Integer] the offset of +elem_after+ in the Enumerable
  attr_reader :offset

  # @return [Object] the element before the cursor, if applicable
  attr_reader :elem_before

  # @return [Object] the element after the cursor, if applicable
  attr_reader :elem_after

  # @return [Boolean] true when {#elem_after} is the first element of the +Enumerable+
  def first?; @is_first; end

  # @return [Boolean] true when {#elem_before} is the last element of the +Enumerable+
  def last?; @is_last; end
end
