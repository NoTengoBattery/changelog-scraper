#!/usr/bin/env ruby

OptionParser.accept(URI) do |url|
  uri = URI.parse(url) if url
  unless uri.is_a?(URI::HTTP)
    raise(OptionParser::InvalidArgument, 'Invalid URL provided, try providing a URL like https://github.com/...')
  end

  uri
end

class GitHubLogManOptparser
  attr_reader :parser, :options

  class ScriptOptions
    attr_reader :verbose, :url, :printer

    def initialize
      @printer = 'interactive'
    end

    def define_options(parser)
      parser.banner = "\e[1mUsage: #{parser.program_name} [options] -u URL
Usage: #{parser.program_name} [options] --url URL\e[0m"
      parser.separator("Options can be 'long' when using the double minus or 'short' when using a single minus.")
      parser.separator('Except for the URL, all options are optional.')
      parser.separator(nil)
      parser.separator("Use \e[4mControl+C\e[0m in the terminal to exit the full-screen view.")
      parser.separator('Use the shell redirection to write out the text-plain view or pipe it to other tools.')
      parser.separator(nil)
      option_verbose(parser)
      option_uri(parser)
      option_printer(parser)
      parser.on_tail('-h', '--help', 'Show this message') do
        puts(parser)
        exit
      end
    end

    private

    def option_verbose(parser)
      parser.on('-v', '--[no-]verbose', 'Run this script with verbose output') { |value| @verbose = value }
    end

    def option_uri(parser)
      parser.on('-u', '--url URL', URI, 'The URL where the changelog is hosted') { |value| @url = value }
    end

    def option_printer(parser)
      parser.on('-p', '--printer PRINTER', String, 'Select the printer method') do |value|
        @printer = value
      end
    end
  end

  def parse(args)
    @options = ScriptOptions.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
      raise(OptionParser::MissingArgument, 'The URL parameter is required') if @options.url.nil?
    end
    @options
  end
end
