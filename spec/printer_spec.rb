#!/usr/bin/env ruby

require_relative '../lib/printer'

PIPE = 'pipe'.freeze
NOT_IMPLEMENTED = 'not-implemented'.freeze

RSpec.describe 'PrinterFactory' do
  let(:factory) { PrinterFactory.new }
  describe 'PipeFactory' do
    it 'returns a Pipe printer when the \'pipe\' keyword is given' do
      expect(factory.build(PIPE)).to be_a(PipePrinter)
    end
    it 'throws an error when an invalid keyword is given' do
      expect { factory.build(NOT_IMPLEMENTED) }.to raise_error(NoPrinterError)
    end
  end
end

RSpec.describe 'Printer' do
  describe 'PipePrinter' do
    let(:pipe) { PrinterFactory.new.build(PIPE) }
    let(:commit1) { Commit.new }
    let(:subject1) { 'Subject1' }
    let(:subject2) { 'Subject2' }
    let(:commit2) { Commit.new }
    let(:pr) { MergeRequest.new }
    it "rejects changelog that is not a #{Changelog}" do
      expect { pipe.print_changelog('hello world') }.to raise_error(ArgumentError)
    end
    it "prints an empty #{String} when a empty #{Changelog} is given" do
      expect { pipe.print_changelog(pr) }.to output('').to_stdout
    end
    it "prints a formated #{String} when a #{Changelog} is given" do
      commit1.subject = subject1
      pr.commits = commit1
      expect { pipe.print_changelog(pr) }.to output("\x1f0\x1f#{subject1}\x1f\n").to_stdout
    end
    it "prints a formated #{String} when a #{Changelog} with more than one #{Commit} is given" do
      commit1.subject = subject1
      commit2.subject = subject2
      pr.commits = commit1
      pr.commits = commit2
      expect { pipe.print_changelog(pr) }.to \
        output("\x1f0\x1f#{subject1}\x1f\n\x1f1\x1f#{subject2}\x1f\n").to_stdout
    end
  end
end
