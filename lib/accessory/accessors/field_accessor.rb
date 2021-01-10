require 'accessory/accessor'

class Accessory::FieldAccessor < Accessory::Accessor
  def initialize(field_name, **kwargs)
    super(**kwargs)
    @getter_method_name = :"#{field_name}"
    @setter_method_name = :"#{field_name}="
  end

  def default_fn_for_previous_step
    lambda do
      require 'ostruct'
      OpenStruct.new
    end
  end

  def value_from(data)
    data.send(@getter_method_name)
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
      data.send(@setter_method_name, new_value)
      [result, data]
    in :pop
      data.send(@setter_method_name, nil)
      [value, data]
    end
  end
end
