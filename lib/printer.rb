#!/usr/bin/env ruby

require_relative 'git'

class NoPrinterError < StandardError; end

module Printer
  def initialize(*); end

  def supports?(keyword)
    MyUtils.pinfo("#{self.class} printer supports '#{keyword}'") if @keyword == keyword
    @keyword == keyword
  end

  def print_changelog(*)
    raise(NotImplementedError, "Please create a printer that inherits from #{Printer}, and implement `print_changelog`")
  end

  private

  def validate_changelog(changelog)
    raise(ArgumentError, "The #{Printer}'s first argument should be a #{Changelog}") unless changelog.is_a?(Changelog)
  end
end

module PrinterFactory
  @printers = []
  class << self
    attr_reader :printers

    def printers=(printer)
      raise(ArgumentError, "The #{PrinterFactory} only accepts #{Printer} subclasses") unless printer < Printer

      @printers << printer
    end

    def build(keyword)
      @printers.each do |printer|
        MyUtils.pinfo("Checking if printer '#{printer}' can handle the selected printer...")
        printer_built = printer.new
        return printer_built if printer_built.supports?(keyword)

        MyUtils.pinfo("Printer '#{printer}' can not handle the selected printer")
      end
      raise(NoPrinterError, "There is no #{Printer} that can handle '#{keyword}'")
    end
  end
end

require_relative 'outputs'
