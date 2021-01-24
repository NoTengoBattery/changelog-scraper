#!/usr/bin/env ruby

require_relative '../lib/argparser'
require_relative '../lib/provider'

begin
  options = GitHubLogManOptparser.new.parse(ARGV)
rescue OptionParser::ParseError => e
  MyUtils.exit_on_exception(
    e, 'For more information about the usage of this script, run it with the -h flag.',
    PARSER_ECODE
  )
end
MyUtils.verbose = options.verbose

MyUtils.note('The program has started. Please wait while the request is completed...')
MyUtils.note(nil)
MyUtils.note('This process may take a while for large changelogs.')
MyUtils.note('Enable the verbose mode to see the proccess as it runs.')
MyUtils.note('For more information about the usage of this script, run it with the -h flag.')
begin
  ProviderFactory.new.build(options.url)
rescue NoProviderError => e
  MyUtils.exit_on_exception(
    e, 'Run this scirpt with the verbose option to see all the available providers. For more help use the -h flag.',
    PARSER_ECODE
  )
rescue HTTP::ConnectionError => e
  MyUtils.exit_on_exception(
    e, 'Provide a valid URL and ensure a stable internet connection.',
    PARSER_ECODE
  )
rescue ScraperError => e
  MyUtils.exit_on_exception(
    e, 'Please report this issue to the mantainer. Enable the verbose mode and send a copy of the full log.',
    PARSER_ECODE
  )
end
MyUtils.note('All information was correctly retrieved from the internet')
