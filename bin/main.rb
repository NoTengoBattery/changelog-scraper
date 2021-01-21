#!/usr/bin/env ruby

require_relative '../lib/argparser'
require_relative '../lib/utilities'

options_parser = GitHubLogManOptparser.new
begin
  options = options_parser.parse(ARGV)
rescue OptionParser::ParseError => e
  MyUtils.perr e
  MyUtils.perr nil
  MyUtils.perr 'For more information about the usage of this script, run it with the -h flag.'
  exit PARSER_ECODE
end
verbose = options.verbose.freeze
url = options.url.freeze

MyUtils.pinfo "URL to request: #{url}" if verbose
begin
  http_object = HTTP.get(url)
  status_code = http_object.status.code
  MyUtils.pinfo "HTTP Request status code: #{status_code}" if verbose
  raise HTTP::ConnectionError, "HTTP request did not succeed: server status code #{status_code}" if status_code != 200
rescue HTTP::ConnectionError => e
  MyUtils.perr e
  MyUtils.perr nil
  MyUtils.perr 'Plese check that your connection is online and that the provided URL is correct.'
  exit HTTP_ECODE
end
MyUtils.pinfo 'Got response from server, ready to parse' if verbose
