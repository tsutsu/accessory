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
  def self.attr(...)
    Accessory::AttributeAccessor.new(...)
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
end

module Accessory::Access::FluentHelpers
  def [](...)
    self.then(Accessory::SubscriptAccessor.new(...))
  end

  def attr(...)
    self.then(Accessory::AttributeAccessor.new(...))
  end

  def ivar(...)
    self.then(Accessory::InstanceVariableAccessor.new(...))
  end

  def betwixt(...)
    self.then(Accessory::BetwixtAccessor.new(...))
  end

  def before_first
    self.betwixt(0)
  end

  def after_last
    self.betwixt(-1)
  end

  def between_each
    self.then(Accessory::BetweenEachAccessor.new)
  end

  def all
    self.then(Accessory::AllAccessor.new)
  end

  def first
    self.then(Accessory::FirstAccessor.new)
  end

  def last
    self.then(Accessory::LastAccessor.new)
  end

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
