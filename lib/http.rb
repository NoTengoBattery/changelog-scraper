#!/usr/bin/env ruby

require_relative '../lib/utilities'

module StrictHTTP
  include HTTP

  PROVIDERS = ['github.com'].freeze
  CHANGELOGS = ['pull'].freeze

  class NoProvierError < StandardError; end

  def self.validate_provider(url)
    string_url = url.to_s
    test = proc do |accumulator, element|
      accumulator |= true if string_url.include?(element)
      accumulator
    end
    valid_provider = PROVIDERS.inject(false, &test)
    valid_changelog = CHANGELOGS.inject(false, &test)

    list = MyUtils.array_to_list(PROVIDERS)
    raise NoProvierError, "The URL is not from a supported provider, supported providers: #{list}" unless valid_provider

    list = MyUtils.array_to_list(CHANGELOGS)
    raise NoProvierError, "The URL has no supported changelog, supported changelogs: #{list}" unless valid_changelog
  end

  def self.strict_get(url, tout)
    http_response = HTTP.timeout(tout).follow.get(url)
    status = http_response.status.code
    success = http_response.status.success?
    raise HTTP::ConnectionError, "HTTP/HTTPS request failed: server status code #{status}" unless success

    http_response
  end
end
