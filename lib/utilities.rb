#!/usr/bin/env ruby

require_relative 'blessings'

module MyUtils
  def self.initialize
    @verbose = false
    @quiet = false
  end

  def self.verbose=(val)
    @verbose = val
  end

  def self.quiet=(val)
    @quiet = val
  end

  def self.perr(arg)
    Blessings.red
    custom_p("ERROR:\t", arg)
    Blessings.reset_color
  end

  def self.pwarn(arg)
    Blessings.yellow
    custom_p("WARNING:\t", arg)
    Blessings.reset_color
  end

  def self.pinfo(arg)
    return if !@verbose or @quiet

    Blessings.blue
    custom_p("INFO:\t", arg)
    Blessings.reset_color
  end

  def self.note(arg)
    return if @quiet

    custom_p("NOTE:\t", arg)
  end

  def self.array_to_list(array)
    array.reduce { |c, v| "#{c}, #{v}" }
  end

  def self.exit_on_exception(exeption, message, code)
    perr("#{exeption.class} ~> #{exeption}")
    perr(nil)
    perr(message)
    exit(code)
  end

  private_class_method def self.custom_p(intro, msg)
    if msg.nil?
      warn(msg)
    else
      warn("#{intro}#{msg}")
    end
  end
end
