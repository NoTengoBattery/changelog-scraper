#!/usr/bin/env ruby

require_relative '../lib/argparser'
require_relative '../lib/http'

options_parser = GitHubLogManOptparser.new
begin
  options = options_parser.parse(ARGV)
rescue OptionParser::ParseError => e
  MyUtils.exit_on_exception(
    e,
    'For more information about the usage of this script, run it with the -h flag.',
    PARSER_ECODE
  )
end
verbose = options.verbose.freeze
url = options.url.freeze

MyUtils.pinfo "URL to request: #{url}" if verbose

begin
  StrictHTTP.validate_provider(url)
rescue StrictHTTP::NoProvierError => e
  MyUtils.exit_on_exception(
    e,
    'Only a small set of providers and changelogs is supported.',
    PROVIDER_ECODE
  )
end

begin
  http_object = StrictHTTP.strict_get(url, 3)
  status = http_object.status.code
  MyUtils.pinfo "HTTP Request status code: #{status}" if verbose
rescue HTTP::ConnectionError, HTTP::TimeoutError => e
  MyUtils.exit_on_exception(
    e,
    'Plese check that your connection is up, working, and that the provided URL is correct.',
    HTTP_ECODE
  )
end
MyUtils.pinfo 'Got response from server, ready to parse' if verbose

document = Nokogiri::HTML(http_object.to_s)

document.css('.js-commit-group-commits').css('.pr-1').css('code').each do |link|
  puts "Commit title => #{link.css('a').first.attributes['title'].value.split("\n").first}"
end
