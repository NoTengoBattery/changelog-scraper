#!/usr/bin/env ruby

require_relative '../lib/argparser'

options_parser = GitHubLogManOptparser.new
options = options_parser.parse(ARGV)
p options.verbose
