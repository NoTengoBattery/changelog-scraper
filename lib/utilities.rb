#!/usr/bin/env ruby

require_relative 'blessings'

module MyUtils
  @verbose = false
  @quiet = false
  class << self
    attr_accessor :verbose, :quiet

    def perr(arg)
      Blessings.red
      custom_p("ERROR:\t", arg)
      Blessings.reset_color
    end

    def pwarn(arg)
      Blessings.yellow
      custom_p("WARNING:\t", arg)
      Blessings.reset_color
    end

    def pinfo(arg)
      return if !@verbose or @quiet

      Blessings.blue
      custom_p("INFO:\t", arg)
      Blessings.reset_color
    end

    def note(arg)
      return if @quiet

      custom_p("NOTE:\t", arg)
    end

    def exit_on_exception(exeption, message, code)
      perr("#{exeption.class} ~> #{exeption}")
      perr(nil)
      perr(message)
      exit(code)
    end
  end
  private_class_method def self.custom_p(intro, msg)
    if msg.nil?
      warn(msg)
    else
      warn("#{intro}#{msg}")
    end
  end
end
