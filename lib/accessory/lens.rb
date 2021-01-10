module Accessory; end

require 'accessory/accessors/subscript_accessor'
require 'accessory/accessors/field_accessor'
require 'accessory/accessors/filter_accessor'
require 'accessory/accessors/instance_variable_accessor'
require 'accessory/accessors/betwixt_accessor'
require 'accessory/accessors/between_each_accessor'
require 'accessory/accessors/all_accessor'
require 'accessory/accessors/first_accessor'
require 'accessory/accessors/last_accessor'

class Accessory::Lens
  def self.[](*path)
    self.new(path)
  end

  def self.field(...)
    Accessory::FieldAccessor.new(...)
  end

  def self.ivar(...)
    Accessory::InstanceVariableAccessor.new(...)
  end

  def self.betwixt(...)
    Accessory::BetwixtAccessor.new(...)
  end

  def self.before_first
    self.betwixt(0)
  end

  def self.after_last
    self.betwixt(-1)
  end

  def self.between_each
    Accessory::BetweenEachAccessor.new
  end

  def self.all
    Accessory::AllAccessor.new
  end

  def self.first
    Accessory::FirstAccessor.new
  end

  def self.last
    Accessory::LastAccessor.new
  end

  def self.filter(&pred)
    Accessory::FilterAccessor.new(pred)
  end

  def initialize(path)
    @path = path.map do |part|
      case part
      when Accessory::Accessor
        part
      when Array
        Accessory::SubscriptAccessor.new(part[0], default: part[1])
      else
        Accessory::SubscriptAccessor.new(part)
      end
    end

    mk_default_fns =
      @path.map(&:default_fn_for_previous_step)[1..-1] + [lambda{ nil }]

    @path.zip(mk_default_fns).each do |(acc, mk_default_fn)|
      acc.make_default_fn = mk_default_fn
    end
  end

  def get_in(doc)
    if @path.empty?
      doc
    else
      get_in_step(doc, @path)
    end
  end

  def get_and_update_in(doc, &mutator_fn)
    if @path.empty?
      doc
    else
      get_and_update_in_step(doc, @path, mutator_fn)
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
