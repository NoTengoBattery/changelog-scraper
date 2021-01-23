#!/usr/bin/env ruby

require_relative '../lib/provider'

OPENWRT_GITHUB = 'https://github.com/openwrt'.freeze
OPENWRT_GITHUB_PR = "#{OPENWRT_GITHUB}/openwrt/pull/1".freeze
FAKE_GITHUB_PR = 'https://github.com/pull'.freeze

RSpec.describe 'ProviderFactory' do
  let(:factory) { ProviderFactory.new }
  let(:no_provider) { URI.parse('https://www.google.com') }
  describe 'GitHubFactory' do
    let(:github) { URI.parse(OPENWRT_GITHUB_PR) }
    let(:github_invalid) { URI.parse(OPENWRT_GITHUB) }
    it 'returns a GitHub provider when a valid GitHub link is given' do
      expect(factory.build(github)).to be_a(GitHubProvider)
    end
    it 'throws an error when an invalid GitHub link is given' do
      expect { factory.build(github_invalid) }.to raise_error(NoProviderError)
    end
    it 'throws an error when a valid URL is given, but is not GitHub' do
      expect { factory.build(no_provider) }.to raise_error(NoProviderError)
    end
  end
end

RSpec.describe 'Provider' do
  describe 'GitHub' do
    let(:fake) { URI.parse(FAKE_GITHUB_PR) }
    let(:github) { URI.parse(OPENWRT_GITHUB_PR) }
    let(:github_invalid) { URI.parse(OPENWRT_GITHUB) }
    let(:github_provider) { GitHubProvider.new(github) }
    it 'scrapes a valid GitHub Pull Request' do
      expect(github_provider).to be_a(GitHubProvider)
      expect(github_provider.valid).to be_truthy
    end
    it 'rejects a GitHub page that is not supported' do
      expect { GitHubProvider.new(github_invalid) }.to raise_error(NoProviderHandlerError)
    end
    it 'rejects a GitHub page that is a fake pull request' do
      expect { GitHubProvider.new(fake) }.to raise_error(ScraperError)
    end
  end
end
