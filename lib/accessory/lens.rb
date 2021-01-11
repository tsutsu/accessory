module Accessory; end

require 'accessory/lens_path'

class Accessory::Lens
  def self.on(subject, path: nil)
    self.new(subject, path || Accessory::LensPath.empty).freeze
  end

  class << self
    private :new
  end

  def initialize(subject, lens_path)
    @subject = subject
    @path = lens_path
  end

  attr_reader :subject
  attr_reader :path

  def inspect
    "#<Lens on=#{@subject.inspect} #{@path.inspect(format: :short)}>"
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

  alias_method :/, :+

  def get_in
    @path.get_in(@subject)
  end

  def get_and_update_in(&mutator_fn)
    @path.get_and_update_in(@subject, &mutator_fn)
  end

  def update_in(&new_value_fn)
    @path.update_in(@subject, &new_value_fn)
  end

  def put_in(new_value)
    @path.put_in(@subject, new_value)
  end

  def pop_in
    @path.pop_in(@subject)
  end
end

class Accessory::LensPath
  def on(subject)
    Accessory::Lens.on(subject, path: self)
  end
end
