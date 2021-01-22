#!/usr/bin/env ruby

require_relative 'git'
require_relative 'http'

class Provider
  attr_reader :valid

  def initialize(*)
    @supported = {}
  end

  private

  def url_validator(url)
    provider = self.class
    @supported.each do |key, val|
      break unless url.host == @host

      MyUtils.pinfo "#{provider}: Checking if changelog type '#{key}' supports this URL..." if $verbose
      next unless url.request_uri.include? key.to_s

      MyUtils.pinfo "#{provider}: Changelog type '#{key}' support this URL" if $verbose
      @valid = true
      @changelog_type = val
      break
    end
    @valid
  end

  def get_html(url)
    MyUtils.pinfo 'Downloading the webpage...' if $verbose
    @dom = Nokogiri::HTML(StrictHTTP.strict_get(url).to_s)
    MyUtils.pinfo 'Webpage downloaded successfully' if $verbose
  end

  def scrape(); end

  def first_line(line)
    line.strip.split("\n").first.strip
  end

  def build_provider(url)
    url_validated = url_validator(url)
    get_html(url) if url_validated
    MyUtils.pinfo 'Executing the scraper...' if $verbose
    scraped = scrape if url_validated
    MyUtils.pinfo "Scraping #{scraped ? 'succeeded' : 'failed'}" if $verbose
  end
end

require_relative 'providers'

class NoProviderError < StandardError; end

class ProviderFactory
  # Add new providers here, just by pushing the class into the @providers array. Do not modify anything else.
  def initialize
    @providers = []
    @providers << GitHub
  end

  def build(url)
    @providers.each do |provider|
      MyUtils.pinfo "Checking if provider '#{provider}' can handle the URL..." if $verbose
      provider_built = provider.new(url)
      return provider_built if provider_built.valid

      MyUtils.pinfo "Provider '#{provider}' can not handle the URL" if $verbose
    end
    raise NoProviderError, 'The given URL is not supported by any provider'
  end
end
