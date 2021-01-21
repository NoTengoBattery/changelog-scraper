#!/usr/bin/env ruby

module StrictHTTP
  include HTTP
  def self.strict_get(url)
    http_response = HTTP.follow.get(url)
    status = http_response.status.code
    success = http_response.status.success?
    raise HTTP::ConnectionError, "HTTP/HTTPS request failed: server status code #{status}" unless success

    http_response
  end
end
