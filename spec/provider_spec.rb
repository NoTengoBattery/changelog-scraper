#!/usr/bin/env ruby

require_relative '../lib/provider'

OPENWRT_GITHUB = 'https://github.com/openwrt'.freeze
OPENWRT_GITHUB_PR = "#{OPENWRT_GITHUB}/openwrt/pull/1".freeze
FAKE_GITHUB_PR = 'https://github.com/pull'.freeze
EMPTY_MESSAGES = 'https://github.com/NoTengoBattery/changelog-scraper/pull/1'.freeze
DELETED_BASE = "#{OPENWRT_GITHUB}/openwrt/pull/4".freeze

RSpec.describe 'ProviderFactory' do
  let(:factory) { ProviderFactory }
  let(:no_provider) { URI.parse('https://www.google.com') }
  describe 'GitHubFactory' do
    let(:github) { URI.parse(OPENWRT_GITHUB_PR) }
    let(:github_invalid) { URI.parse(OPENWRT_GITHUB) }
    it 'returns a GitHub provider when a valid GitHub link is given' do
      expect(factory.build(github)).to be_a(GitHubScraper)
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
  describe 'GitHubScraper' do
    let(:fake) { URI.parse(FAKE_GITHUB_PR) }
    let(:github) { URI.parse(OPENWRT_GITHUB_PR) }
    let(:github_invalid) { URI.parse(OPENWRT_GITHUB) }
    let(:gh_empty_commit) { URI.parse(EMPTY_MESSAGES) }
    let(:gh_del_base) { URI.parse(DELETED_BASE) }
    let(:github_scraper) { ProviderFactory.build(github) }
    it 'scrapes a valid GitHub Pull Request' do
      github_scraper.build_from(github)
      expect(github_scraper.valid).to be_truthy
    end
    it 'can handle Pull Request with empty message commits' do
      github_scraper.build_from(gh_empty_commit)
      expect(github_scraper.valid).to be_truthy
    end
    it 'can handle Pull Request deleted base branch' do
      github_scraper.build_from(gh_del_base)
      expect(github_scraper.valid).to be_truthy
    end
    it 'rejects a GitHub page that is not supported' do
      expect { github_scraper.build_from(github_invalid) }.to raise_error(NotImplementedError)
    end
    it 'rejects a GitHub page that is a fake pull request' do
      expect { github_scraper.build_from(fake) }.to raise_error(NotImplementedError)
    end
  end
end
