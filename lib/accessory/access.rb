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

##
# A set of convenient module-function helpers to use with <tt>Lens[...]</tt>.
#
# These functions aren't very convenient unless you
#
#    include Accessory

module Accessory::Access
  # (see Accessory::Accessors::SubscriptAccessor)
  def self.subscript(...)
    Accessory::Accessors::SubscriptAccessor.new(...)
  end

  # (see Accessory::Accessors::AttributeAccessor)
  def self.attr(...)
    Accessory::Accessors::AttributeAccessor.new(...)
  end

  # (see Accessory::Accessors::InstanceVariableAccessor)
  def self.ivar(...)
    Accessory::Accessors::InstanceVariableAccessor.new(...)
  end

  # (see Accessory::Accessors::BetwixtAccessor)
  def self.betwixt(...)
    Accessory::Accessors::BetwixtAccessor.new(...)
  end

  # Alias for +Accessory::Accessors::Access.betwixt(0)+. See {Access.betwixt}
  def self.before_first
    self.betwixt(0)
  end

  # Alias for +Accessory::Accessors::Access.betwixt(-1)+. See {Access.betwixt}
  def self.after_last
    self.betwixt(-1)
  end

  # (see Accessory::Accessors::BetweenEachAccessor)
  def self.between_each
    Accessory::Accessors::BetweenEachAccessor.new
  end

  # (see Accessory::Accessors::AllAccessor)
  def self.all
    Accessory::Accessors::AllAccessor.new
  end

  # (see Accessory::Accessors::FirstAccessor)
  def self.first
    Accessory::Accessors::FirstAccessor.new
  end

  # (see Accessory::Accessors::LastAccessor)
  def self.last
    Accessory::Accessors::LastAccessor.new
  end

  # (see Accessory::Accessors::FilterAccessor)
  def self.filter(&pred)
    Accessory::Accessors::FilterAccessor.new(pred)
  end
end

##
# A set of convenient "fluent API" builder methods
# that get mixed into {Lens} and {BoundLens}.
#
# These do the same thing as the {Access} helper of the same name, but
# wrap the resulting accessor in a call to <tt>#then</tt>, deriving a new
# {Lens} or {BoundLens} from the addition of the accessor.

module Accessory::Access::FluentHelpers
  # (see Accessory::Accessors::SubscriptAccessor)
  def subscript(...)
    self.then(Accessory::Accessors::SubscriptAccessor.new(...))
  end

  # Alias for {#subscript}
  def [](...)
    self.then(Accessory::Accessors::SubscriptAccessor.new(...))
  end

  # (see Accessory::Accessors::AttributeAccessor)
  def attr(...)
    self.then(Accessory::Accessors::AttributeAccessor.new(...))
  end

  # (see Accessory::Accessors::InstanceVariableAccessor)
  def ivar(...)
    self.then(Accessory::Accessors::InstanceVariableAccessor.new(...))
  end

  # (see Accessory::Accessors::BetwixtAccessor)
  def betwixt(...)
    self.then(Accessory::Accessors::BetwixtAccessor.new(...))
  end

  # Alias for +#betwixt(0)+. See {#betwixt}
  def before_first
    self.betwixt(0)
  end

  # Alias for +#betwixt(-1)+. See {#betwixt}
  def after_last
    self.betwixt(-1)
  end

  # (see Accessory::Accessors::BetweenEachAccessor)
  def between_each
    self.then(Accessory::Accessors::BetweenEachAccessor.new)
  end

  # (see Accessory::Accessors::AllAccessor)
  def all
    self.then(Accessory::Accessors::AllAccessor.new)
  end

  # (see Accessory::Accessors::FirstAccessor)
  def first
    self.then(Accessory::Accessors::FirstAccessor.new)
  end

  # (see Accessory::Accessors::LastAccessor)
  def last
    self.then(Accessory::Accessors::LastAccessor.new)
  end

  # (see Accessory::Accessors::FilterAccessor)
  def filter(&pred)
    self.then(Accessory::Accessors::FilterAccessor.new(pred))
  end
end

class Accessory::Lens
  include Accessory::Access::FluentHelpers
end

class Accessory::BoundLens
  include Accessory::Access::FluentHelpers
end
