module Accessory; end

class Accessory::Accessor
  DEFAULT_NOT_SET_SENTINEL = :"98e47971-e708-42ca-bee7-0c62fe5e11c9"

  def initialize(default: DEFAULT_NOT_SET_SENTINEL)
    @default_value = default
  end

  def name
    n = self.class.name.split('::').last.gsub(/Accessor$/, '')
    n.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    n.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    n.tr!("-", "_")
    n.downcase!
    n
  end

  def inspect(format: :long)
    case format
    when :long
      parts = ["Access.#{self.name}", inspect_args].compact.join(' ')
      "#<#{parts}>"
    when :short
      fn_name = "Access.#{self.name}"
      args = inspect_args
      args ? "#{fn_name}(#{args})" : fn_name
    end
  end

  HIDDEN_IVARS = [:@default_value, :@make_default_fn]
  def inspect_args
    (instance_variables - HIDDEN_IVARS).map do |ivar_k|
      ivar_v = instance_variable_get(ivar_k)
      "#{ivar_k}=#{ivar_v.inspect}"
    end.join(' ')
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
