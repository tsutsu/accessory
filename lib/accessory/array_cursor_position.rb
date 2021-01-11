module Accessory; end

##
# Represents a cursor-position "between" two positions in an +Array+ or other
# integer-indexed +Enumerable+.

class Accessory::ArrayCursorPosition
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

  # @return [Object] true when {#elem_after} is the first element of the +Enumerable+
  def first?; @is_first; end

  # @return [Object] true when {#elem_before} is the last element of the +Enumerable+
  def last?; @is_last; end
end
