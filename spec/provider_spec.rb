#!/usr/bin/env ruby

require_relative '../lib/provider'

RSpec.describe 'ProviderFactory' do
  let(:factory) { ProviderFactory.new }
  let(:no_provider) { URI.parse('https://www.google.com') }
  describe 'GitHubFactory' do
    let(:github) { URI.parse('https://github.com/openwrt/openwrt/pull/1') }
    let(:github_invalid) { URI.parse('https://github.com/openwrt') }
    it 'returns a GitHub provider when a valid GitHub link is given' do
      factory.build(github)
    end
    it 'throws an error when an invalid GitHub link is given' do
      expect { factory.build(github_invalid) }.to raise_error(NoProviderError)
    end
    it 'throws an error when a valid URL is given, but is not GitHub' do
      expect { factory.build(no_provider) }.to raise_error(NoProviderError)
    end
  end
end
