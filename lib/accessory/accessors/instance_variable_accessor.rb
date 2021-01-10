require 'accessory/accessor'

class Accessory::InstanceVariableAccessor < Accessory::Accessor
  def initialize(ivar_name, **kwargs)
    super(**kwargs)

    ivar_name = ivar_name.to_s
    ivar_name = "@#{ivar_name}" unless ivar_name.to_s.start_with?("@")
    ivar_name = ivar_name.intern

    @ivar_name = ivar_name
  end

  def inspect_args
    @ivar_name.to_s
  end

  def default_fn_for_previous_step
    lambda{ Object.new }
  end

  def value_from(data)
    data.instance_variable_get(@ivar_name)
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
      data.instance_variable_set(@ivar_name, new_value)
      [result, data]
    in :pop
      data.remove_instance_variable(@ivar_name)
      [value, data]
    end
  end
end
