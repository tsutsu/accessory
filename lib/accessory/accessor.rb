module Accessory; end

class Accessory::Accessor
  DEFAULT_NOT_SET_SENTINEL = :"98e47971-e708-42ca-bee7-0c62fe5e11c9"

  def initialize(default: DEFAULT_NOT_SET_SENTINEL)
    @default_value = default
  end

  attr_accessor :make_default_fn

  def value_or_default(data)
    return nil if data.nil?

    maybe_value = value_from(data)
    return maybe_value unless maybe_value.nil?

    if DEFAULT_NOT_SET_SENTINEL.equal?(@default_value)
      @make_default_fn.call
    else
      @default_value
    end
  end
end
