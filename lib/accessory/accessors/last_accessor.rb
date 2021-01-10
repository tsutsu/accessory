require 'accessory/accessor'

class Accessory::LastAccessor < Accessory::Accessor
  def default_fn_for_previous_step
    lambda{ Array.new }
  end

  def inspect_args; nil; end

  def value_from(data)
    data.last
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
      data[-1] = new_value
      [result, data]
    in :pop
      data.delete_at(-1)
      [old_value, data]
    end
  end
end
