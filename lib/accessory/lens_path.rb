module Accessory; end

require 'accessory/accessor'
require 'accessory/accessors/subscript_accessor'

class Accessory::LensPath
  def self.empty
    @empty_lens_path ||= (new([]).freeze)
  end

  def self.[](*path)
    new(path).freeze
  end

  class << self
    private :new
  end

  def initialize(initial_parts)
    @parts = []

    for part in initial_parts
      append_accessor!(part)
    end
  end

  def to_a
    @parts
  end

  def inspect(format: :long)
    parts_desc = @parts.map{ |part| part.inspect(format: :short) }.join(', ')
    parts_desc = "[#{parts_desc}]"

    case format
    when :long
      "#LensPath#{parts_desc}"
    when :short
      parts_desc
    end
  end

  def then(accessor)
    d = self.dup
    d.append_accessor!(accessor)
    d.freeze
  end

  def dup
    d = super
    d.instance_eval do
      @parts = @parts.dup
    end
    d
  end

  def +(lp_b)
    parts =
      case lp_b
      when Accessory::LensPath
        lp_b.to_a
      when Array
        lp_b
      else
        [lp_b]
      end

    d = self.dup
    for part in parts
      d.append_accessor!(part)
    end
    d.freeze
  end

  alias_method :/, :+

  def append_accessor!(part)
    accessor =
      case part
      when Accessory::Accessor
        part
      when Array
        Accessory::SubscriptAccessor.new(part[0], default: part[1])
      else
        Accessory::SubscriptAccessor.new(part)
      end

    unless @parts.empty?
      @parts.last.make_default_fn = accessor.default_fn_for_previous_step
    end

    @parts.push(accessor)
  end

  protected :append_accessor!

  def get_in(doc)
    if @parts.empty?
      doc
    else
      get_in_step(doc, @parts)
    end
  end

  def get_and_update_in(doc, &mutator_fn)
    if @parts.empty?
      doc
    else
      get_and_update_in_step(doc, @parts, mutator_fn)
    end
  end

  def update_in(data, &new_value_fn)
    _, new_data = self.get_and_update_in(data){ |v| [nil, new_value_fn.call(v)] }
    new_data
  end

  def put_in(data, new_value)
    _, new_data = self.get_and_update_in(data){ [nil, new_value] }
    new_data
  end

  def pop_in(data)
    self.get_and_update_in(data){ :pop }
  end

  private
  def get_in_step(data, path)
    step_accessor = path.first
    rest_of_path = path[1..-1]

    if rest_of_path.empty?
      step_accessor.get(data)
    else
      step_accessor.get(data){ |v| get_in_step(v, rest_of_path) }
    end
  end

  private
  def get_and_update_in_step(data, path, mutator_fn)
    step_accessor = path.first
    rest_of_path = path[1..-1]

    if rest_of_path.empty?
      step_accessor.get_and_update(data, &mutator_fn)
    else
      step_accessor.get_and_update(data){ |v| get_and_update_in_step(v, rest_of_path, mutator_fn) }
    end
  end
end
