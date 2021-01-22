#!/usr/bin/env ruby

require_relative 'providers'

class NoProvierError < StandardError
end

class ProviderFactory
  def initialize
    @providers = []
    @providers << GitHub
  end

  def build(url)
    @providers.each do |provider|
      provider_built = provider.new(url)
      return new_provider if provider_built.valid
    end
    raise NoProvierError, 'The given URL does not match any know provider'
  end
end
