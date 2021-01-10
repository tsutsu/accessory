require 'accessory/accessor'

class Accessory::AllAccessor < Accessory::Accessor
  def default_fn_for_previous_step
    lambda{ Array.new }
  end

  def inspect_args; nil; end

  def get(data, &succ)
    if succ
      (data || []).map(&succ)
    else
      data
    end
  end

  def get_and_update(data)
    results = []
    new_data = []

    (data || []).each do |pos|
      case yield(pos)
      in [result, new_value]
        results.push(result)
        new_data.push(new_value)
      in :pop
        results.push(pos)
      end
    end

    [results, new_data]
  end
end
