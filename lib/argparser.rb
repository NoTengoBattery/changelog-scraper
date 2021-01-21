#!/usr/bin/env ruby

OptionParser.accept(URI) do |url|
  uri = URI.parse(url) if url
  raise 'Invalid URL provied, try providing a URL like https://github.com/...' unless uri.is_a?(URI::HTTP)

  uri
end

class GitHubLogManOptparser
  class ScriptOptions
    attr_reader :verbose, :url

    def initialize
      @verbose = false
      @url = nil
    end

    def option_verbose(parser)
      parser.on('-v', '--[no-]verbose', 'Run this script with verbose output') { |value| @verbose = value }
    end

    def option_uri(parser)
      parser.on('-u', '--url URL', URI, 'The URL where the changelog is hosted') { |value| @url = value }
    end

    def define_options(parser)
      parser.banner =
        "\e[1m
Usage: #{parser.program_name} [options] -u URL
Usage: #{parser.program_name} [options] --url URL\e[0m"
      parser.separator "Options can be 'long' when using the double minus or 'short' when using a single minus."
      parser.separator 'Except for the URL, all options are optional.'
      parser.separator nil
      parser.separator "Use \e[4mControl+C\e[0m in the terminal to exit the full-screen view."
      parser.separator 'Use the shell redirection to write out the text-plain view into a file.'
      parser.separator nil
      option_verbose(parser)
      option_uri(parser)
      parser.on_tail('-h', '--help', 'Show this message') do
        puts parser
        exit
      end
    end
  end

  def parse(args)
    @options = ScriptOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
      raise OptionParser::MissingArgument, 'The URL parameter is required' if @options.url.nil?
    end
    @options
  end

  attr_reader :parser, :options
end
