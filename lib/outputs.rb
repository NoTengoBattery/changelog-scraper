#!/usr/bin/env ruby

class PipePrinter
  include Printer
  def initialize
    super
    @keyword = 'pipe'
  end

  def print_changelog(changelog, _kwargs = {})
    validate_changelog(changelog)
    changelog.commits.each_with_index do |commit, index|
      # 0x1D is the ASCII code for the Field Separator character, which does exactly that
      printf("\x1d%<index>s\x1d%<subject>s\x1d\n", index: index, subject: commit.subject)
    end
  end
end
PrinterFactory.printers = PipePrinter
