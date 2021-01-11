module Accessory; end

require 'accessory/lens_path'

class Accessory::Lens
  # Creates a Lens that will traverse +subject+ along +lens_path+.
  # @param subject [Object] the data-structure this Lens will traverse
  # @param lens_path [LensPath] the {LensPath} that will be used to traverse +subject+
  def self.on(subject, lens_path: Accessory::LensPath.empty)
    self.new(subject, path).freeze
  end

  class << self
    private :new
  end

  # @!visibility private
  def initialize(subject, lens_path)
    @subject = subject
    @path = lens_path
  end

  # @return [LensPath] the +subject+ this Lens will traverse
  attr_reader :subject

  # @return [LensPath] the {LensPath} for this Lens
  attr_reader :path

  # @!visibility private
  def inspect
    "#<Lens on=#{@subject.inspect} #{@path.inspect(format: :short)}>"
  end

  # Returns a new Lens resulting from appending +accessor+ to the receiver's
  # {LensPath}.
  #
  # === See also:
  # * {LensPath#then}
  #
  # @param accessor [Object] the accessor to append
  # @return [LensPath] the new Lens, containing a new joined LensPath
  def then(accessor)
    d = self.dup
    d.instance_eval do
      @path = @path.then(accessor)
    end
    d.freeze
  end

  # Returns a new Lens resulting from concatenating +other+ to the receiver's
  # {LensPath}.
  #
  # === See also:
  # * {LensPath#+}
  #
  # @param other [Object] an accessor, an +Array+ of accessors, or a {LensPath}
  # @return [LensPath] the new Lens, containing a new joined LensPath
  def +(other)
    d = self.dup
    d.instance_eval do
      @path = @path + other
    end
    d.freeze
  end

  alias_method :/, :+

  # (see LensPath#get_in)
  def get_in
    @path.get_in(@subject)
  end

  # (see LensPath#get_and_update_in)
  def get_and_update_in(&mutator_fn)
    @path.get_and_update_in(@subject, &mutator_fn)
  end

  # (see LensPath#update_in)
  def update_in(&new_value_fn)
    @path.update_in(@subject, &new_value_fn)
  end

  # (see LensPath#put_in)
  def put_in(new_value)
    @path.put_in(@subject, new_value)
  end

  # (see LensPath#pop_in)
  def pop_in
    @path.pop_in(@subject)
  end
end

class Accessory::LensPath
  # Returns a new {Lens} wrapping this LensPath, bound to the specified
  # +subject+.
  # @param subject [Object] the data-structure to traverse
  # @return [Lens] a new Lens that will traverse +subject+ using this LensPath
  def on(subject)
    Accessory::Lens.on(subject, lens_path: self)
  end
end
