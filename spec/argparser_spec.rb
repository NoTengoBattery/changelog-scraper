#!/usr/bin/env ruby

require_relative '../lib/argparser'

RSpec.describe 'GitHubLogManOptparser' do
  let(:options_parser) { GitHubLogManOptparser.new }
  let(:minimal_args) { ['-u', 'http://example.com'] }
  let(:no_args) { [] }
  it 'turns on verbose mode using long option' do
    minimal_args << '--verbose'
    options = options_parser.parse(minimal_args)
    expect(options.verbose).to be_truthy
  end
  it 'turns on verbose mode using short option' do
    minimal_args << '-v'
    options = options_parser.parse(minimal_args)
    expect(options.verbose).to be_truthy
  end
  it 'turns off verbose mode' do
    minimal_args << '--no-verbose'
    options = options_parser.parse(minimal_args)
    expect(options.verbose).to be_falsy
  end
  it 'accepts a valid HTTP/HTTPS URL using long option' do
    no_args << '--url'
    no_args << 'https://example.com'
    options = options_parser.parse(no_args)
    expect(options.url).to be_a(URI::HTTP)
  end
  it 'accepts a valid HTTP/HTTPS URL using short option' do
    no_args << '-u'
    no_args << 'https://example.com'
    options = options_parser.parse(no_args)
    expect(options.url).to be_a(URI::HTTP)
  end
  it 'rejects a set of parameters without URL' do
    no_args << '--verbose'
    expect { options_parser.parse(no_args) }.to raise_error(OptionParser::MissingArgument)
  end
  it 'rejects a set of parameters with an invalid URL' do
    no_args << '-u'
    no_args << 'google.com'
    expect { options_parser.parse(no_args) }.to raise_error(OptionParser::InvalidArgument)
  end
  it 'rejects a set of invalid parameters' do
    no_args << '--invalid-argument'
    expect { options_parser.parse(no_args) }.to raise_error(OptionParser::InvalidOption)
  end
  it 'rejects a set of malformed parameters' do
    no_args << '-u'
    expect { options_parser.parse(no_args) }.to raise_error(OptionParser::MissingArgument)
  end
end
