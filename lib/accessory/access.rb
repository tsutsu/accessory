module Accessory; end

require 'accessory/accessors/subscript_accessor'
require 'accessory/accessors/attribute_accessor'
require 'accessory/accessors/filter_accessor'
require 'accessory/accessors/instance_variable_accessor'
require 'accessory/accessors/betwixt_accessor'
require 'accessory/accessors/between_each_accessor'
require 'accessory/accessors/all_accessor'
require 'accessory/accessors/first_accessor'
require 'accessory/accessors/last_accessor'

module Accessory::Access
  # (see Accessory::SubscriptAccessor)
  def self.subscript(...)
    Accessory::SubscriptAccessor.new(...)
  end

  # (see Accessory::AttributeAccessor)
  def self.attr(...)
    Accessory::AttributeAccessor.new(...)
  end

  # (see Accessory::InstanceVariableAccessor)
  def self.ivar(...)
    Accessory::InstanceVariableAccessor.new(...)
  end

  # (see Accessory::BetwixtAccessor)
  def self.betwixt(...)
    Accessory::BetwixtAccessor.new(...)
  end

  # Alias for +Accessory::Access.betwixt(0)+. See {Access.betwixt}
  def self.before_first
    self.betwixt(0)
  end

  # Alias for +Accessory::Access.betwixt(-1)+. See {Access.betwixt}
  def self.after_last
    self.betwixt(-1)
  end

  # (see Accessory::BetweenEachAccessor)
  def self.between_each
    Accessory::BetweenEachAccessor.new
  end

  # (see Accessory::AllAccessor)
  def self.all
    Accessory::AllAccessor.new
  end

  # (see Accessory::FirstAccessor)
  def self.first
    Accessory::FirstAccessor.new
  end

  # (see Accessory::LastAccessor)
  def self.last
    Accessory::LastAccessor.new
  end

  # (see Accessory::FilterAccessor)
  def self.filter(&pred)
    Accessory::FilterAccessor.new(pred)
  end
end

module Accessory::Access::FluentHelpers
  # (see Accessory::SubscriptAccessor)
  def subscript(...)
    self.then(Accessory::SubscriptAccessor.new(...))
  end

  # Alias for {#subscript}
  def [](...)
    self.then(Accessory::SubscriptAccessor.new(...))
  end

  # (see Accessory::AttributeAccessor)
  def attr(...)
    self.then(Accessory::AttributeAccessor.new(...))
  end

  # (see Accessory::InstanceVariableAccessor)
  def ivar(...)
    self.then(Accessory::InstanceVariableAccessor.new(...))
  end

  # (see Accessory::BetwixtAccessor)
  def betwixt(...)
    self.then(Accessory::BetwixtAccessor.new(...))
  end

  # Alias for +#betwixt(0)+. See {#betwixt}
  def before_first
    self.betwixt(0)
  end

  # Alias for +#betwixt(-1)+. See {#betwixt}
  def after_last
    self.betwixt(-1)
  end

  # (see Accessory::BetweenEachAccessor)
  def between_each
    self.then(Accessory::BetweenEachAccessor.new)
  end

  # (see Accessory::AllAccessor)
  def all
    self.then(Accessory::AllAccessor.new)
  end

  # (see Accessory::FirstAccessor)
  def first
    self.then(Accessory::FirstAccessor.new)
  end

  # (see Accessory::LastAccessor)
  def last
    self.then(Accessory::LastAccessor.new)
  end

  # (see Accessory::FilterAccessor)
  def filter(&pred)
    self.then(Accessory::FilterAccessor.new(pred))
  end
end

class Accessory::Lens
  include Accessory::Access::FluentHelpers
end

class Accessory::LensPath
  include Accessory::Access::FluentHelpers
end
