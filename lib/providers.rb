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
    provider = self.class
    @supported.each do |key, val|
      break unless url.host == @host

      MyUtils.pinfo "#{provider}: Checking if changelog type '#{key}' supports this URL..." if $verbose
      request = url.request_uri
      next unless request.include? key.to_s

      MyUtils.pinfo "#{provider}: Changelog type '#{key}' support this URL" if $verbose
      @valid = true
      @changelog = val
      break
    end
    @valid
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
