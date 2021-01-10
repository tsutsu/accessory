module Accessory; end

require 'accessory/version'
require 'accessory/lens_path'
require 'accessory/lens'
require 'accessory/access'

module Accessory
  refine ::Object do
    def lens
      ::Accessory::Lens.on(self)
    end
  end
end
