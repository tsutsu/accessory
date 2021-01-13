module Accessory; end

##
# The parent class for accessors. Contains some shared behavior all accessors
# can rely on.
#
# It doesn't make sense to instantiate this class directly. Instantiate specific
# {Accessor} subclasses instead.
#
# == Implementing an Accessor
#
# To implement an {Accessor} subclass, you must define at minimum these two
# methods (see the method docs of these methods for details):
#
# * {Accessor#get}
# * {Accessor#get_and_update}
#
# You may also implement these two methods (again, see method docs for more
# info):
#
# * {Accessor#traverse}
# * {Accessor#ensure_valid}

class Accessory::Accessor
  TERMINAL_DEFAULT_FN = lambda{ nil }
  private_constant :TERMINAL_DEFAULT_FN

  # @!visibility private
  def initialize(default_value = nil)
    @default_value = default_value
  end

  # @!visibility private
  def name
    n = self.class.name.split('::').last.gsub(/Accessor$/, '')
    n.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    n.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    n.tr!("-", "_")
    n.downcase!
    n
  end

  # @!visibility private
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

  # @!visibility private
  HIDDEN_IVARS = [:@default_value, :@successor]
  private_constant :HIDDEN_IVARS

  # @!visibility private
  def inspect_args
    (instance_variables - HIDDEN_IVARS).map do |ivar_k|
      ivar_v = instance_variable_get(ivar_k)
      "#{ivar_k}=#{ivar_v.inspect}"
    end.join(' ')
  end

  # @!visibility private
  attr_accessor :successor

  # @!group Helpers

  # Safely traverses +data+, with useful defaults; simplifies implementations of
  # {get} and {get_and_update}.
  #
  # Rather than writing redundant traversal logic into both methods, you can
  # implement the callback method {traverse} to define your traversal, and then
  # call <tt>traverse_or_default(data)</tt> within your implementation to safely
  # get a traversal-result to operate on.
  #
  # The value returned by your {traverse} callback will be validated by your
  # calling the {ensure_valid} callback of the _successor accessor_ in the Lens
  # path. {ensure_valid} will replace any value it considers invalid with a
  # reasonable default. This means you don't need to worry about what will
  # happen if your traversal doesn't find a value and so returns +nil+. The
  # successor's {ensure_valid} will replace that +nil+ with a value that works
  # for it.
  def traverse_or_default(data)
    traversal_result = traverse(data) || @default_value

    if @successor
      @successor.ensure_valid(traversal_result)
    else
      traversal_result
    end
  end

  # @!endgroup

  # Traverses +data+ in some way, and feeds the result of the traversal to the
  # next step in the accessor chain by yielding the traversal-result to the
  # passed-in block +succ+. The result from the yield is the result coming from
  # the end of the accessor chain. Usually, it should be returned as-is.
  #
  # +succ+ can be yielded to multiple times, to run the rest of the accessor
  # chain against multiple parts of +data+. In this case, the yield results
  # should be gathered up into some container object to be returned together.
  #
  # The successor accessor will receive the yielded element as its +data+.
  #
  # After returning, the predecessor accessor will receive the result returned
  # from {get} as the result of its own +yield+.
  #
  # @param data [Enumerable] the data yielded by the predecessor accessor.
  # @param succ [Proc] a thunk to the successor accessor. When {get} is called
  #   by a {Lens}, this is passed implicitly.
  # @return [Object] the data to pass back to the predecessor accessor as a
  #   yield result.
  def get(data, &succ)
    raise NotImplementedError, "Accessor subclass #{self.class} must implement #get"
  end

  # Traverses +data+ in some way, and feeds the result of the traversal to the
  # next step in the accessor chain by yielding the traversal-result to the
  # passed-in block +succ+.
  #
  # The result of the yield will be a "modification command", one of these two:
  # * an *update command* <tt>[get_result, new_value]</tt>
  # * the symbol <tt>:pop</tt>
  #
  # In the *update command* case:
  # * the +get_result+ should be returned as-is (or gathered together into
  #   a container object if this accessor yields multiple times.) The data flow
  #   of the +get_result+s should replicate the data flow of {get}.
  # * the +new_value+ should be used to *replace* or *overwrite* the result of
  #   this accessor's traversal within +data+. For example, in
  #   {SubscriptAccessor}, <tt>data[key] = new_value</tt> is executed.
  #
  # In the <tt>:pop</tt> command case:
  # * the result of the traversal (*before* the yield) should be returned. This
  #   implies that any {get_and_update} implementation must capture its
  #   traversal-results before feeding them into yield, in order to return them
  #   here.
  # * the traversal-result should be *removed* from +data+. For example, in
  #   {SubscriptAccessor}, <tt>data.delete(key)</tt> is executed.
  #
  # The successor in the accessor chain will receive the yielded
  # traversal-results as its own +data+.
  #
  # After returning, the predecessor accessor will receive the result returned
  # from this method as the result of its own +yield+. This implies that
  # this method should almost always be implemented to *return* an update
  # command, looking like one of the following:
  #
  #   # given [get_result, new_value]
  #   [get_result, data_after_update]
  #
  #   # given :pop
  #   [traversal_result, data_after_removal]
  #
  # @param data [Enumerable] the data yielded by the predecessor accessor.
  # @param succ [Proc] a thunk to the successor accessor. When {get} is called
  #   by a {Lens}, this is passed implicitly.
  # @return [Object] the modification-command to pass back to the predecessor
  #   accessor as a yield result.
  def get_and_update(data, &succ)
    raise NotImplementedError, "Accessor subclass #{self.class} must implement #get_and_update"
  end

  # @!group Callbacks

  # Traverses +data+; called by {traverse_or_default}.
  #
  # This method should traverse +data+ however your accessor does that,
  # producing either one traversal-result or a container-object of gathered
  # traversal-results.
  #
  # This method can assume that +data+ is a valid receiver for the traversal
  # it performs. {traverse_or_default} takes care of feeding in a default +data+
  # in the case where the predecessor passed invalid data.
  #
  # @param data [Object] the object to be traversed
  # @return [Object] the result of traversal
  def traverse(data)
    raise NotImplementedError, "Accessor subclass #{self.class} must implement #traverse to use #traverse_or_default"
  end

  # Ensures that the predecessor accessor's traversal result is one this
  # accessor can operate on; called by {traverse_or_default}.
  #
  # This callback should validate that the +traversal_result+ is one that can
  # be traversed by the traversal-method of this accessor. If it can, the
  # +traversal_result+ should be returned unchanged. If it cannot, an object
  # that _can_ be traversed should be returned instead.
  #
  #
  # For example, if your accessor operates on +Enumerable+ values (like
  # {AllAccessor}), then this method should validate that the +traversal_result+
  # is +Enumerable+; and, if it isn't, return something that is — e.g. an empty
  # +Array+.
  #
  # This logic is used to replace invalid intermediate values (e.g. `nil`s and
  # scalars) with containers during {Lens#put_in} et al.
  #
  # @return [Object] a now-valid traversal result
  def ensure_valid(traversal_result)
    lambda do
      raise NotImplementedError, "Accessor subclass #{self.class} must implement #ensure_valid to allow chain-predecessor to use #traverse_or_default"
    end
  end

  # @!endgroup
end

module Accessory::Accessors; end
