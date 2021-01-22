#!/usr/bin/env ruby

require_relative '../lib/argparser'
require_relative '../lib/provider'

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
$verbose = options.verbose.freeze
url = options.url.freeze

MyUtils.pinfo "User provided URL: #{url}" if $verbose
ProviderFactory.new.build(url)
