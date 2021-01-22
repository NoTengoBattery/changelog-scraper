#!/usr/bin/env ruby

require_relative 'http'
require_relative 'git'

class Provider
  attr_reader :host, :valid

  def initialize(*)
    @host = 'nodomain.com'
    @name = 'Generic Provider'
    @changelog = MergeRequest
    @supported = {}
    @valid = false
  end

  private

  def url_validator(url)
    @supported.each do |key, val|
      break if url.host == @host

      request = url.request_uri
      next unless request.include? key.to_s

      @valid = true
      @changelog = val
      break
    end
  end

  def get_html(url); end
end

# - if you want to extend the functionality, add more providers here and don't forget to add them to the factory too -

class GitHub < Provider
  def initialize(url)
    super
    @host = 'github.com'
    @name = 'GitHub'
    @supported[:pull] = MergeRequest
    get_html(url) if url_validator(url)
  end
end
