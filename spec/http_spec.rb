#!/usr/bin/env ruby

require_relative '../lib/http'

RSpec.describe 'StrictHTTP' do
  let(:valid_but_error) { 'https://google.com/notfound' }
  let(:valid_but_nx) { 'http://nx-domain.com' }
  let(:timeout) { 'https://gi.com' }
  let(:good) { 'https://github.com' }
  it 'rejects valid URLs that return HTTP error codes' do
    expect { StrictHTTP.strict_get(valid_but_error, 3) }.to raise_error(HTTP::ConnectionError)
  end
  it 'rejects valid URLs that lead to DNS NXDOMAIN' do
    expect { StrictHTTP.strict_get(valid_but_nx, 3) }.to raise_error(HTTP::ConnectionError)
  end
  it 'rejects valid URLs that lead to timeout' do
    expect { StrictHTTP.strict_get(timeout, 3) }.to raise_error(HTTP::TimeoutError)
  end
  it 'accepts valid HTTP URLs that return HTTP success codes' do
    expect { StrictHTTP.strict_get(good, 3) }.not_to raise_error
  end
end
