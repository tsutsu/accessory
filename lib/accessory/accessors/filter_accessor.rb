require 'accessory/accessor'

class Accessory::FilterAccessor < Accessory::Accessor
  def initialize(pred)
    @pred = pred
  end

  def default_fn_for_previous_step
    lambda{ Array.new }
  end

  def get(data, &succ)
    if succ
      (data || []).filter(&@pred).map(&succ)
    else
      data
    end
  end

  def get_and_update(data)
    results = []
    new_data = []

    (data || []).each do |pos|
      unless @pred.call(pos)
        new_data.push(pos)
        next
      end

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
