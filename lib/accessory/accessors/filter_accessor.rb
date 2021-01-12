require 'accessory/accessor'

##
# Traverses the elements of an +Enumerable+ that return a truthy value from
# a passed-in predicate block.
#
# *Aliases*
# * {Access.filter}
# * {Access::FluentHelpers#filter} (included in {Lens} and {BoundLens})
#
# *Equivalents* in Elixir's {https://hexdocs.pm/elixir/Access.html +Access+} module
# * {https://hexdocs.pm/elixir/Access.html#filter/1 +Access.filter/1+}
#
# <b>Default constructor</b> used by predecessor accessor
#
# * +Array.new+

class Accessory::FilterAccessor < Accessory::Accessor
  # Returns a new instance of {FilterAccessor}.
  #
  # The predicate function may be passed in as either a positional argument,
  # or a block.
  #
  # @param pred [Proc] The predicate function to use, as an object
  # @param pred_blk [Proc] The predicate function to use, as a block
  # @param default [Object] the default to use if the predecessor accessor passes +nil+ data
  def initialize(pred = nil, default: nil, &pred_blk)
    @pred = blk || pred
  end

  # @!visibility private
  def inspect_args
    @pred.inspect
  end

  # @!visibility private
  def default_data_constructor
    lambda{ Array.new }
  end

  # Feeds each element of +data+ matching the predicate down the accessor chain,
  # returning the results.
  # @param data [Enumerable] the +Enumerable+ to iterate through
  # @return [Array] the values derived from the rest of the accessor chain
  def get(data, &succ)
    if succ
      (data || []).filter(&@pred).map(&succ)
    else
      data
    end
  end

  # Feeds each element of +data+ matching the predicate down the accessor chain,
  # overwriting +data+ with the results.
  #
  # If +:pop+ is returned from the accessor chain, the element is dropped
  # from the new +data+.
  #
  # @param data [Enumerable] the +Enumerable+ to iterate through
  # @return [Array] a two-element array containing 1. the original values found during iteration; and 2. the new +data+
  def get_and_update(data)
    results = []
    new_data = []

    (data || []).each do |pos|
      unless @pred.call(pos)
        new_data.push(pos)
        next
      end

      case yield(pos)
      in [result, new_value]
        results.push(result)
        new_data.push(new_value)
      in :pop
        results.push(pos)
      end
    end

    [results, new_data]
  end
end
