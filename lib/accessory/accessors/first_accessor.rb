require 'accessory/accessor'

class Accessory::FirstAccessor < Accessory::Accessor
  def default_fn_for_previous_step
    lambda{ Array.new }
  end

  def value_from(data)
    data.first
  end

  def get(data)
    value = value_or_default(data)

    if block_given?
      yield(value)
    else
      value
    end
  end

  def get_and_update(data)
    old_value = value_or_default(data)

    case yield(old_value)
    in [result, new_value]
      data[0] = new_value
      [result, data]
    in :pop
      data.delete_at(0)
      [old_value, data]
    end
  end
end
