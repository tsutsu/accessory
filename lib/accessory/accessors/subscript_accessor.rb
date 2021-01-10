require 'accessory/accessor'

class Accessory::SubscriptAccessor < Accessory::Accessor
  def initialize(key, **kwargs)
    super(**kwargs)
    @key = key
  end

  def inspect(format: :long)
    case format
    when :long
      super()
    when :short
      @key.inspect
    end
  end

  def inspect_args
    @key.inspect
  end

  def default_fn_for_previous_step
    lambda{ Hash.new }
  end

  def value_from(data)
    data[@key]
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
    value = value_or_default(data)

    case yield(value)
    in [result, new_value]
      data[@key] = new_value
      [result, data]
    in :pop
      data.delete(@key)
      [value, data]
    end
  end
end
