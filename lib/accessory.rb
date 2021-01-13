module Accessory; end

require 'accessory/version'
require 'accessory/lens'
require 'accessory/bound_lens'
require 'accessory/access'

module Accessory
  refine ::Object do
    def lens(...)
      ::Accessory::BoundLens.on(self, ...)
    end
  end
end
