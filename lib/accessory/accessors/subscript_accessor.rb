require 'accessory/accessor'

##
# Traverses into a specified +key+ for an arbitrary container-object which supports the +#[]+ and +#[]=+ methods.
#
# @param key [Object] the key to pass to the +#[]+ and +#[]=+ methods.
#
# *Aliases*
# * {Access.subscript}
# * {Access::FluentHelpers#subscript} (included in {Lens} and {BoundLens})
# * {Access::FluentHelpers#[]} (included in {Lens} and {BoundLens})
# * just passing a +key+ will also work, when +not(key.kind_of?(Accessor))+
#   (this is a special case in {Lens#initialize})
#
# *Equivalents* in Elixir's {https://hexdocs.pm/elixir/Access.html +Access+} module
# * {https://hexdocs.pm/elixir/Access.html#at/1 +Access.at/1+}
# * {https://hexdocs.pm/elixir/Access.html#key/2 +Access.key/2+}
#
# <b>Default constructor</b> used by predecessor accessor
#
# * +Hash.new+
#
# == Usage Notes:
# Subscripting into an +Array+ will *work*, but may not have the results you expect:
#
#   # extends the Array
#   [].lens[3].put_in(1) # => [nil, nil, nil, 1]
#
#   # default-constructs a Hash, not an Array
#   [].lens[0][0].put_in(1) # => [{0=>1}]
#
# Other accessors ({FirstAccessor}, {BetwixtAccessor}, etc.) may fit your expectations more closely for +Array+ traversal.

class Accessory::SubscriptAccessor < Accessory::Accessor
  # @!visibility private
  def initialize(key, **kwargs)
    super(**kwargs)
    @key = key
  end

  # @!visibility private
  def inspect(format: :long)
    case format
    when :long
      super()
    when :short
      @key.inspect
    end
  end

  # @!visibility private
  def inspect_args
    @key.inspect
  end

  # @!visibility private
  def ensure_valid(traversal_result)
    if traversal_result.respond_to?(:[])
      traversal_result
    else
      {}
    end
  end

  # @!visibility private
  def traverse(data)
    data[@key]
  end

  # Finds <tt>data[@key]</tt>, feeds it down the accessor chain, and returns
  # the result.
  # @param data [Enumerable] the +Enumerable+ to index into
  # @return [Object] the value derived from the rest of the accessor chain
  def get(data)
    value = traverse_or_default(data)

    if block_given?
      yield(value)
    else
      value
    end
  end

  # Finds <tt>data[@key]</tt>, feeds it down the accessor chain, and overwrites
  # <tt>data[@key]</tt> with the returned result.
  #
  # If +:pop+ is returned from the accessor chain, the key is instead deleted
  # from the {data} with <tt>data.delete(@key)</tt>.
  # @param data [Enumerable] the +Enumerable+ to index into
  # @return [Array] a two-element array containing 1. the original value found; and 2. the result value from the accessor chain
  def get_and_update(data)
    value = traverse_or_default(data)

    case yield(value)
    in [result, new_value]
      data[@key] = new_value
      [result, data]
    in :pop
      data.delete(@key)
      [value, data]
    end
  end
end
