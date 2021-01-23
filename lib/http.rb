#!/usr/bin/env ruby

require_relative 'utilities'

module StrictHTTP
  include HTTP
  def self.strict_get(url, tout = 10)
    MyUtils.pinfo("Starting HTTP request to '#{url}' with timeout #{tout}...")
    http_response = HTTP.timeout(tout).follow.get(url)
    status = http_response.status.code
    success = http_response.status.success?
    raise(HTTP::ConnectionError, "HTTP/HTTPS request failed: server status code #{status}") unless success

    MyUtils.pinfo("Successful HTTP request to '#{url}'")
    http_response
  end
end
