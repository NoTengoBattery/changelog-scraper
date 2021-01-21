#!/usr/bin/env ruby

require_relative 'blessings'

module MyUtils
  private_class_method def self.custom_p(intro, msg)
    if msg.nil?
      warn msg
    else
      warn("#{intro}: #{msg}")
    end
  end

  def self.perr(args)
    Blessings.red
    custom_p('ERROR', args)
    Blessings.reset_color
  end

  def self.pwarn(args)
    Blessings.yellow
    custom_p('WARNING', args)
    Blessings.reset_color
  end

  def self.pinfo(args)
    Blessings.blue
    custom_p('INFO', args)
    Blessings.reset_color
  end
end
