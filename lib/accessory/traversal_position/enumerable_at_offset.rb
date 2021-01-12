module Accessory; end
module Accessory::TraversalPosition; end

##
# Represents an element encountered during +#each+ traversal of an +Enumerable+.

class Accessory::TraversalPosition::EnumerableAtOffset
  ##
  # @!visibility private
  def initialize(offset, elem_at, is_first: false, is_last: false)
    @offset = offset
    @elem_at = elem_at
    @is_first = is_first
    @is_last = is_last
  end

  # @return [Integer] the offset of +elem_at+ in the Enumerable
  attr_reader :offset

  # @return [Object] the element under the cursor, if applicable
  attr_reader :elem_at

  # @return [Boolean] true when {#elem_at} is the first element of the +Enumerable+
  def first?; @is_first; end

  # @return [Boolean] true when {#elem_at} is the last element of the +Enumerable+
  def last?; @is_last; end
end
