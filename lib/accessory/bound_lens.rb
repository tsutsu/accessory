module Accessory; end

require 'accessory/lens'

##
# A BoundLens represents a {Lens} bound to a specified subject document.
# See {Lens} for the general theory.
#
# A BoundLens can be used to traverse its subject document, using {get_in},
# {put_in}, {pop_in}, etc.
#
# Ordinarily, you don't create and hold onto a BoundLens, but rather you will
# temporarily create Lenses in method-call chains when doing traversals.
#
# It may sometimes be useful to create a collection of Lenses and then "build
# them up" by extending their {Lens}es over various collection-passes, rather
# than building up {Lens}es and only binding them to subjects at the end.
#
# Lenses are created frozen. Methods that "extend" a BoundLens actually
# create and return new derived Lenses.

class Accessory::BoundLens

  # Creates a BoundLens that will traverse +subject+.
  #
  # @overload on(subject, lens)
  #   Creates a BoundLens that will traverse +subject+ along +lens+.
  #
  #   @param subject [Object] the data-structure this BoundLens will traverse
  #   @param lens [Lens] the {Lens} that will be used to traverse +subject+
  #
  # @overload on(subject, *accessors)
  #   Creates a BoundLens that will traverse +subject+ using a {Lens} built
  #   from +accessors+.
  #
  #   @param subject [Object] the data-structure this BoundLens will traverse
  #   @param accessors [Array] the accessors for the new {Lens}
  def self.on(subject, *accessors)
    lens =
      if accessors.length == 1 && accessors[0].kind_of?(Lens)
        accessors[0]
      else
        Accessory::Lens[*accessors]
      end

    self.new(subject, lens).freeze
  end

  class << self
    private :new
  end

  # @!visibility private
  def initialize(subject, lens)
    @subject = subject
    @lens = lens
  end

  # @return [Lens] the +subject+ this BoundLens will traverse
  attr_reader :subject

  # @return [Lens] the {Lens} for this BoundLens
  attr_reader :lens

  # @!visibility private
  def inspect
    "#<BoundLens on=#{@subject.inspect} #{@lens.inspect(format: :short)}>"
  end

  # Returns a new BoundLens resulting from appending +accessor+ to the
  # receiver's {Lens}.
  #
  # === See also:
  # * {Lens#then}
  #
  # @param accessor [Object] the accessor to append
  # @return [Lens] the new BoundLens, containing a new joined Lens
  def then(accessor)
    d = self.dup
    d.instance_eval do
      @lens = @lens.then(accessor)
    end
    d.freeze
  end

  # Returns a new BoundLens resulting from concatenating +other+ to the
  # receiver's {Lens}.
  #
  # === See also:
  # * {Lens#+}
  #
  # @param other [Object] an accessor, an +Array+ of accessors, or a {Lens}
  # @return [Lens] the new BoundLens, containing a new joined Lens
  def +(other)
    d = self.dup
    d.instance_eval do
      @lens = @lens + other
    end
    d.freeze
  end

  alias_method :/, :+

  # (see Lens#get_in)
  def get_in
    @lens.get_in(@subject)
  end

  # (see Lens#get_and_update_in)
  def get_and_update_in(&mutator_fn)
    @lens.get_and_update_in(@subject, &mutator_fn)
  end

  # (see Lens#update_in)
  def update_in(&new_value_fn)
    @lens.update_in(@subject, &new_value_fn)
  end

  # (see Lens#put_in)
  def put_in(new_value)
    @lens.put_in(@subject, new_value)
  end

  # (see Lens#pop_in)
  def pop_in
    @lens.pop_in(@subject)
  end
end

class Accessory::Lens
  # Returns a new {BoundLens} wrapping this Lens, bound to the specified
  # +subject+.
  # @param subject [Object] the data-structure to traverse
  # @return [BoundLens] a new BoundLens that will traverse +subject+ using
  #   this Lens
  def on(subject)
    Accessory::BoundLens.on(subject, self)
  end
end
