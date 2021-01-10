require 'accessory/accessor'
require 'accessory/array_cursor_position'

class Accessory::BetweenEachAccessor < Accessory::Accessor
  def default_fn_for_previous_step
    lambda{ Array.new }
  end

  def value_from(data)
    data_len = data.length

    positions = [
      (0..data_len).to_a,
      data + [nil],
      [nil] + data
    ]

    positions.transpose.map do |(i, b, a)|
      Accessory::ArrayCursorPosition.new(i, b, a, is_first: i == 0, is_last: i == data_len)
    end
  end

  def get(data)
    positions = value_or_default(data || [])

    if block_given?
      positions.map{ |rec| yield(rec) }
    else
      positions
    end
  end

  def get_and_update(data)
    results = []
    new_data = []

    positions = value_or_default(data || [])

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
