# frozen_string_literal: true

require_relative 'lib/accessory/version'

Gem::Specification.new do |spec|
  spec.name          = 'accessory'
  spec.license       = 'MIT'
  spec.version       = Accessory::VERSION
  spec.authors       = ['Levi Aul']
  spec.email         = ['levi@leviaul.com']

  spec.summary       = %q{Functional lenses for Ruby, borrowed from Elixir}
  spec.homepage      = 'https://github.com/tsutsu/accessory'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files         = Dir['lib/**/*.rb'] + Dir['A-Z*']

  spec.require_paths = ['lib']
end
