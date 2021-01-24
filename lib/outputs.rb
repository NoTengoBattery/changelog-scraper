#!/usr/bin/env ruby

class Pipe
  include Printer
  def initialize
    super
    @keyword = 'pipe'
  end
end
