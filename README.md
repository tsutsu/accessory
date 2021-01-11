# Accessory

Accessory is a Ruby re-interpretation of Elixir's particular implementation of functional lenses.

* Like Elixir, Accessory provides functions called `get_in`, `update_in`, `pop_in`, `put_in`, `get_and_update_in`, etc., that each take a "lens path" and traverse it.

* Like Elixir, Accessory's lens paths are composed of "accessors" — you'll find most of the same ones from Elixir's [`Access` module](https://hexdocs.pm/elixir/Access.html) (insofar as they make sense in Ruby), and also some uniquely-Ruby accessors as well.

* Like Elixir, these lens paths are detached from any source, and so are reusable (they can be e.g. set as module-level constants.)

* Unlike Elixir, where lenses are plain lists and accessors are closures, Accessory's lenses and accessors are objects. The traversal functions are all methods on the `Accessory::LensPath`.

* Also unlike Elixir, Accessory's mutative traversals (`update_in`, `put_in`, etc.) modify the input document *in place*. (Non-in-place accessors are also planned.)

# Usage

#### Getting Started

```sh
$ gem install accessory
```

```ruby
require 'accessory'
```

#### A Basic Example

```ruby
require 'accessory'
include Accessory

doc = {}
LensPath[:foo, Access.first, "bar"].put_in(doc, :baz)
doc # => {foo: [{"bar" => :baz}]}

LensPath[:foo, Access.after_last, "bar"].put_in(doc, :quux)
doc # => {foo: [{"bar" => :baz}, {"bar" => :quux}]}

LensPath[:foo, Access.all, "bar"].get_in(doc) # => [:baz, :quux]
```

#### Functional API

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

#### Fluent API

Rather than constructing a `LensPath` all at once, you can also construct it through a chain of method-calls that closely resemble what would be done if you were traversing from the root of a subject document.

The fluent builder methods available are the same as the `Access` module functions.

```ruby
include Accessory

# the following are equivalent:
LensPath[Access.first, :foo, Access.all, "bar"]

LensPath.empty.first[:foo].all["bar"]
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

#### Lenses

A `LensPath` may be bound to a subject document, producing a `Lens`:

```ruby
doc = {foo: 1}
doc_foo = LensPath[:foo].on(doc) # => #<Lens on={:foo=>1} [:foo]>
```

A `Lens` exposes the same traversal methods as a `LensPath`, but does not require that you pass in a document, as it already has its own:

```ruby
doc_foo.get_in # => 1
doc_foo.put_in(2) # => {:foo=>2}
doc # => {:foo=>2}
```

In all other respects, a `Lens` is a decorator for a `LensPath`. Specifically, `.then` (and the related fluent helper-methods) and `+` both work to extend the `LensPath` of the `Lens` (producing a new `Lens` containing a new `LensPath`):

```ruby
doc = {}
doc_foo = LensPath[:foo].on(doc) # => #<Lens on={} [:foo]>
doc_foo_bar = doc_foo[:bar]      # => #<Lens on={} [:foo, :bar]>
```

#### The `.lens` Refinement

By `using Accessory`, a `.lens` method is added to all `Object`s, which has the same meaning as passing the object to `Accessory::Lens.on`.

```ruby
using Accessory
{}.lens[:foo][:bar].put_in(5) # => {:foo=>{:bar=>5}}
```
