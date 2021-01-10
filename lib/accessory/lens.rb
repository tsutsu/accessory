module Accessory; end

require 'accessory/lens_path'

class Accessory::Lens
  def self.on(doc, path: nil)
    self.new(doc, path || Accessory::LensPath.empty).freeze
  end

  class << self
    private :new
  end

  def initialize(doc, lens_path)
    @doc = doc
    @path = lens_path
  end

  attr_reader :path

  def inspect
    "#<Lens on=#{@doc.inspect} #{@path.inspect(format: :short)}>"
  end

  def then(accessor)
    d = self.dup
    d.instance_eval do
      @path = @path.then(accessor)
    end
    d.freeze
  end

  def +(lens_path)
    d = self.dup
    d.instance_eval do
      @path = @path + lens_path
    end
    d.freeze
  end

  def get_in
    @path.get_in(@doc)
  end

  def get_and_update_in(&mutator_fn)
    @path.get_and_update_in(@doc, &mutator_fn)
  end

  def update_in(&new_value_fn)
    @path.update_in(@doc, &new_value_fn)
  end

  def put_in(new_value)
    @path.put_in(@doc, new_value)
  end

  def pop_in
    @path.pop_in(@doc)
  end
end

class Accessory::LensPath
  def on(doc)
    Accessory::Lens.on(doc, path: self)
  end
end
