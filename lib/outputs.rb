#!/usr/bin/env ruby

class PipePrinter
  include Printer
  def initialize
    super
    @keyword = 'pipe'
  end

  def print_changelog(changelog)
    validate_changelog(changelog)
    changelog.commits.each_with_index do |commit, index|
      printf("\x1f%<index>s\x1f%<subject>s\x1f\n", index: index, subject: commit.subject)
    end
  end
end
