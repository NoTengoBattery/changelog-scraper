#!/usr/bin/env ruby

OptionParser.accept(URI) do |url|
  uri = URI.parse(url) if url
  raise(OptionParser::InvalidArgument, '~> invalid URL, provide a valid HTTP/HTTPS URL') unless uri.class <= URI::HTTP

  uri
end

class GitHubLogManOptparser
  attr_reader :parser, :options

  class ScriptOptions
    attr_reader :verbose, :url, :printer

    def initialize
      @printer = 'pipe'
    end

    def define_options(parser)
      parser.banner = "\e[1mUsage: #{parser.program_name} [options] -u URL
Usage: #{parser.program_name} [options] --url URL\e[0m"
      parser.separator("Options can be 'long' when using the double minus or 'short' when using a single minus.")
      parser.separator("Except for the URL, all options are optional. The default printer is '#{@printer}'.")
      parser.separator(nil)
      parser.separator("Use \e[4mControl+C\e[0m in the terminal to exit the interactive view.")
      parser.separator('For the pipe printer, use the shell redirection to pipe the output to other tools.')
      parser.separator("For the interactive printer, use the arrow keys and \e[4mEnter\e[0m or \e[4mSpace\e[0m.")
      parser.separator('For the Markdown printer, provide a valid Markdown file with the replacement mark.')
      parser.separator(nil)
      parser.separator("Maintainer:\t#{MAINTAINER}")
      option_verbose(parser)
      option_uri(parser)
      option_printer(parser)
      parser.on_tail('-h', '--help', 'Show this help message and exit') do
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
      raise(OptionParser::MissingArgument, '~> the URL parameter is required') if @options.url.nil?
    end
    @options
  end
end
