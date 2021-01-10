require 'accessory/accessor'
require 'accessory/array_cursor_position'

class Accessory::BetwixtAccessor < Accessory::Accessor
  def initialize(offset, **kwargs)
    super(**kwargs)
    @offset = offset
  end

  def default_fn_for_previous_step
    lambda{ Array.new }
  end

  def value_from(data)
    data_len = data.length

    Accessory::ArrayCursorPosition.new(
      @offset,
      (@offset > 0) ? data[@offset - 1] : nil,
      (@offset < (data_len - 1)) ? data[@offset + 1] : nil,
      is_first: @offset == 0,
      is_last: @offset == data_len
    )
  end

  def get(data)
    pos = value_or_default(data || [])

    if block_given?
      yield(pos)
    else
      pos
    end
  end

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
