#!/usr/bin/env ruby

class GitHubLogManOptparser
  class ScriptOptions
    attr_accessor :verbose

    def initialize
      self.verbose = false
    end

    def option_verbose(parser)
      parser.on('-v', '--[no-]verbose', 'Run this script with verbose output') do |value|
        self.verbose = value
      end
    end

    def define_options(parser)
      parser.banner = "\e[1mUsage: #{parser.program_name} [options] URL\e[0m"
      parser.separator "Options can be 'long' when using the double minus or 'short' when using a single minus."
      parser.separator 'Except for the URL and the type of changelog that the URL represents, all options are optional.'
      parser.separator nil
      parser.separator 'Use Control+C in the terminal to exit the full-screen view.'
      parser.separator 'Use the shell redirection to write out the text-plain view into a file.'
      parser.separator nil
      option_verbose(parser)
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
    end
    @options
  end

  attr_reader :parser, :options
end
