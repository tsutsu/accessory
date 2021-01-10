# Accessory

Accessory is a Ruby re-interpretation of Elixir's particular implementation of functional lenses.

* Like Elixir, Accessory provides functions called `get_in`, `update_in`, `pop_in`, `put_in`, `get_and_update_in`, etc., that each take a "lens path" and traverse it.

* Like Elixir, Accessory's lens paths are composed of "accessors" — you'll find most of the same ones from Elixir's [`Access` module](https://hexdocs.pm/elixir/Access.html) (insofar as they make sense in Ruby), and also some uniquely-Ruby accessors as well.

* Like Elixir, these lens paths are detached from any source, and so are reusable (they can be e.g. set as module-level constants.)

* Unlike Elixir, where lenses are plain lists and accessors are closures, Accessory's lenses and accessors are objects. The traversal functions are all methods on the `Accessory::Lens`.

* Also unlike Elixir, Accessory's mutative traversals (`update_in`, `put_in`, etc.) modify the input document *in place*. (Non-in-place accessors are also planned.)

# Usage

```ruby
require 'accessory'

doc = {}
Lens[:foo, Lens.first, "bar"].put_in(doc, :baz)
doc # => {foo: [{"bar" => :baz}]}

Lens[:foo, Lens.after_last, "bar"].put_in(doc, :quux)
doc # => {foo: [{"bar" => :baz}, {"bar" => :quux}]}

Lens[:foo, Lens.all, "bar"].get_in(doc) # => [:baz, :quux]
```
