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
      MyUtils.pinfo "Checking if provider '#{provider}' can handle the URL..." if $verbose
      provider_built = provider.new(url)
      return provider_built if provider_built.valid

      MyUtils.pinfo "Provider '#{provider}' can not handle the URL" if $verbose
    end
    raise NoProvierError, 'The given URL is not supported by any provider'
  end
end
