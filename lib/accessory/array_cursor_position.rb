module Accessory; end

class Accessory::ArrayCursorPosition
  def initialize(offset, elem_before, elem_after, is_first: false, is_last: false)
    @offset = offset
    @elem_before = elem_before
    @elem_after = elem_after
    @is_first = is_first
    @is_last = is_last
  end

  attr_reader :offset
  attr_reader :elem_before
  attr_reader :elem_after

  def first?; @is_first; end
  def last?; @is_last; end
end
