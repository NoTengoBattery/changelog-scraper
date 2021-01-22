#!/usr/bin/env ruby

require_relative 'blessings'

module MyUtils
  private_class_method def self.custom_p(intro, msg)
    if msg.nil?
      warn msg
    else
      warn("#{intro}#{msg}")
    end
  end

  def self.perr(arg)
    Blessings.red
    custom_p('ERROR: ', arg)
    Blessings.reset_color
  end

  def self.pex(arg)
    Blessings.red
    custom_p("ERROR: #{arg.class} ~> ", arg)
    Blessings.reset_color
  end

  def self.pwarn(arg)
    Blessings.yellow
    custom_p('WARNING: ', arg)
    Blessings.reset_color
  end

  def self.pinfo(arg)
    Blessings.blue
    custom_p('INFO: ', arg)
    Blessings.reset_color
  end

  def self.array_to_list(array)
    array.reduce { |c, v| "#{c}, #{v}" }
  end

  def self.exit_on_exception(exeption, message, code)
    perr exeption
    perr nil
    perr message
    exit code
  end
end
