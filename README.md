# Accessory

Accessory is a Ruby re-interpretation of Elixir's particular implementation of functional lenses.

* Like Elixir, Accessory provides functions called `get_in`, `update_in`, `pop_in`, `put_in`, `get_and_update_in`, etc., that each take a "lens path" and traverse it.

* Like Elixir, Accessory's lens paths are composed of "accessors" — you'll find most of the same ones from Elixir's [`Access` module](https://hexdocs.pm/elixir/Access.html) (insofar as they make sense in Ruby), and also some uniquely-Ruby accessors as well.

* Like Elixir, these lens paths are detached from any source, and so are reusable (they can be e.g. set as module-level constants.)

* Unlike Elixir, where lenses are plain lists and accessors are closures, Accessory's lenses and accessors are objects. The traversal functions are all methods on the `Accessory::LensPath`.

* Also unlike Elixir, Accessory's mutative traversals (`update_in`, `put_in`, etc.) modify the input document *in place*. (Non-in-place accessors are also planned.)

## Installation

```sh
$ gem install accessory
```

## Usage

```ruby
require 'accessory'
```

### `LensPath`

An `Accessory::LensPath` is a "free-floating" lens (not bound to a subject document.)

```ruby
Accessory::LensPath[:foo, "bar", 0]
```

Accessors are classes named like `Accessory::FooAccessor`. You can create and use accessors directly in a `LensPath`:

```ruby
Accessory::LensPath[Accessory::SubscriptAccessor.new(:foo)]
```

...or use the convenience module-functions on `Accessory::Access`:

```ruby
include Accessory
LensPath[Access.subscript(:foo)] # equivalent to the above
```

Also, as an additional convenience, LensPath will wrap any raw objects (objects not descended from `Accessory::Accessor`) in a `SubscriptAccessor`. So another way to write the above is:

```ruby
Accessory::LensPath[:foo]
```

You can define your own accessor classes by inheriting from `Accessory::Accessor`, and use them in a `LensPath` as normal.

```ruby
class MyAccessor < Accessory::Accessor
  # ...
end

Accessory::LensPath[MyAccessor.new(:bar)]
```

#### Extending LensPaths

Existing `LensPath`s may be "extended" with additional path-components using `.then`:

```ruby
lp = LensPath[Access.first, :foo, Access.all]
lp.then("bar") # => #LensPath[Access.first, :foo, Access.all, "bar"]
```

`LensPath` instances are created frozen; each use of `.then` produces a new child `LensPath`, rather than affecting the original. This allows you to reuse "base" `LensPath`s.

`LensPath`s may also be concatenated using `+`, again producing a new `LensPath` instance:

```ruby
lp1 = LensPath[Access.first, :foo]
lp2 = LensPath[Access.all, "bar"]
lp1 + lp2 # => #LensPath[Access.first, :foo, Access.all, "bar"]
```

`+` also allows "bald" accessors, or plain arrays of accessors:

```ruby
LensPath[:foo] + :bar + [:baz, :quux] # => #LensPath[:foo, :baz, :baz, :quux]
```

Another name for `+` is `/`. This allows for a traveral syntax similar to `Pathname` instances:

```ruby
LensPath.empty / :foo / :bar # => #LensPath[:foo, :bar]
```

#### Fluent API

Methods with the same names as the module-functions in `Access` are included in `LensPath`. Calling these methods has the same effect as calling the relevant module-function and passing it to `.then`.

These methods allow you to construct a `LensPath` through a chain of method-calls that closely resembles a concrete traversal of a container-object.

```ruby
include Accessory

# the following are equivalent:
LensPath[Access.first, :foo, Access.all, "bar"]

LensPath.empty.first[:foo].all["bar"]
```

You can combine your own accessors with the fluent methods by using `.then`:

```ruby
Accessor::LensPath.empty[:foo].first.then(MyAccessor.new)[:baz]
```

### `Lens`

A `LensPath` may be bound to a subject document with `LensPath#on` to produce a `Lens`:

```ruby
doc = {foo: 1}
doc_foo = LensPath[:foo].on(doc) # => #<Lens on={:foo=>1} [:foo]>
```

Alternately, you can use `Lens.on(doc)` to create an identity `Lens`:

```ruby
doc = {foo: 1}
Lens.on(doc) # => #<Lens on={:foo=>1} []>
```

A `Lens` exposes the same traversal methods as a `LensPath`, but does not require that you pass in a document, as it already has its own:

```ruby
doc_foo.get_in # => 1
doc_foo.put_in(2) # => {:foo=>2}
doc # => {:foo=>2}
```

A `Lens` also exposes all the extension methods of its `LensPath`. Like a `LensPath`, a `Lens` is frozen, so these methods return a new `Lens` wrapping a new `LensPath`:

```ruby
doc = {}
doc_root = Lens.on(doc)     # => #<Lens on={} []>
doc_foo  = doc_root / :foo  # => #<Lens on={} [:foo]>
```

#### The `.lens` refinement

By `using Accessory`, a `.lens` method is added to all `Object`s, which has the same meaning as passing the object to `Lens.on`.

```ruby
using Accessory
{}.lens[:foo][:bar].put_in(5) # => {:foo=>{:bar=>5}}
```

### Default inference for intermediate accessors

Every accessor knows how to construct a valid, empty value of the type it expects to receive as input. For example, the `AllAccessor` expects to operate on `Enumerables`, and so defines a default constructor of `Array.new`.

When a `LensPath` is created, the default constructors for each accessor are "fed back" through to their predecessor accessor. The predecessor stores the default constructor to use as a fall-back default (i.e. a default for when you didn't explicitly specify a default.)

This means that you usually don't need to specify defaults in your accessors, because sensible values are inferred from the next operation in the `LensPath` traversal chain.

Let's annotate a `LensPath` with the inferred defaults for each traversal-step:

```ruby
LensPath[
  :foo,        # Array.new (AllAccessor)
  Access.all,  # OpenStruct.new (AttributeAccessor)
  attr(:name), # Hash.new (SubscriptAccessor)
  :bar         # nil (no successor)
]
```

## Built-in Accessors

### `SubscriptAccessor`

* Aliases: `key`, `LensPath#[key]`

* Elixir equivalents: [`Access.at/1`](https://hexdocs.pm/elixir/Access.html#at/1), [`Access.key/2`](https://hexdocs.pm/elixir/Access.html#key/2)

* Default constructor: `Hash.new`

Traverses into the specified `key` for an arbitrary container-object supporting the `.[]` and `.[]=` methods.

### `AllAccessor`

* Aliases: `Access.all`, `LensPath#all`

* Elixir equivalent: [`Access.all/0`](https://hexdocs.pm/elixir/Access.html#all/0)

* Default constructor: `Array.new`

Traverses all elements of an array.

### `FilterAccessor`

* Aliases: `Access.filter(&pred)`, `LensPath#filter(&pred)`

* Elixir equivalent: [`Access.filter/1`](https://hexdocs.pm/elixir/Access.html#filter/1)

* Default constructor: `Array.new`

Traverses only the elements of an array that return a truthy value for the passed-in block.

### `FirstAccessor`

* Aliases `Access.first`, `LensPath#first`

* Default constructor: `Array.new`

Traverses the first element of an array.

Using `FirstAccessor` with `put_in` will *overwrite* the existing first element of an array, *not* insert a new element. If you want to insert a new element at the beginning of the array, use `.before_first`.

### `LastAccessor`

* Aliases `Access.last`, `LensPath#last`

* Default constructor: `Array.new`

Traverses the last element of an array.

Using `LastAccessor` with `put_in` will *overwrite* the existing last element of an array, *not* insert a new element. If you want to insert a new element at the end of the array, use `.after_last`.

### `BetweenEachAccessor`

* Aliases: `Access.between_each`, `LensPath#between_each`

* Default constructor: `Array.new`

Traverses the positions "between" array elements, including the positions at the "edges" of the array.

If `between_each` positions are targeted with `put_in`, you can insert new elements between the existing ones in an array.

### `BetwixtAccessor`

* Aliases: `Access.betwixt(offset)`, `LensPath#betwixt(offset)`

* Helpers:

  * `.before_first` (equivalent to `.betwixt(0)`)
  * `.after_last` (equivalent to `.betwixt(-1)`)

* Default constructor: `Array.new`

Traverses "between" two array elements.

If `offset` is positive, this traverses the position between `offset - 1`  and `offset`; if `offset` is negative, this traverses the position *after* `offset`.

The offset in this accessor has equivalent semantics to the offset in `Array#insert(offset, obj)`.

`betwixt` can be used with `put_in` to insert elements between existing ones in an array, or at the beginning or end of an array.

### `AttributeAccessor`

* Aliases: `Access.attr(name)`, `LensPath#attr(name)`

* Default constructor: `OpenStruct.new`

Traverses an abstract "attribute" of an arbitrary object, represented by a named getter/setter method pair. For example, given `.attr(:foo)`, the getter/setter method pair `.foo` and `.foo=` will be traversed.

### `InstanceVariableAccessor`

* Aliases: `Access.ivar(name)`, `LensPath#ivar(name)`

* Default constructor: `Object.new`

Traverses into an instance-variable of an arbitrary object. For example, given `.ivar(:foo)`, the instance-variable `@foo` of the object will be traversed.
