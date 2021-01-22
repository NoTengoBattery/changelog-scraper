#!/usr/bin/env ruby

require_relative 'git'
require_relative 'http'

module Provider
  attr_reader :valid

  def initialize(*)
    @supported = {}
  end

  private

  def url_validator(url)
    provider = self.class
    @supported.each do |key, val|
      break unless url.host == @host

      MyUtils.pinfo "#{provider}: Checking if changelog type '#{key}' supports this URL..."
      next unless url.request_uri.include? key.to_s

      MyUtils.pinfo "#{provider}: Changelog type '#{key}' support this URL"
      @valid = true
      @changelog_type = val
      break
    end
    @valid
  end

  def get_html(url)
    MyUtils.pinfo 'Downloading the webpage...'
    @dom = Nokogiri::HTML(StrictHTTP.strict_get(url).to_s)
    MyUtils.pinfo 'Webpage downloaded successfully'
  end

  def scrape()
    raise NotImplementedError, "Please create a provider than inherits from #{Provider} and implement `scrape`."
  end

  def first_line(line)
    line.strip.split("\n").first
  end

  def build_provider(url)
    url_validator(url)
    get_html(url) if @valid
    MyUtils.pinfo "Scraping a #{self.class} #{@changelog_type}..." if @valid
    scraped = scrape if @valid
    @dom = nil
    MyUtils.pinfo "Scraping #{scraped ? 'succeeded' : 'failed'}"
  end
end

class NoProviderError < StandardError; end

class ScraperError < StandardError; end

require_relative 'providers'

class ProviderFactory
  # Add new providers here by pushing the class into the @providers array. Do not modify anything else.
  def initialize
    @providers = []
    @providers << GitHubProvider
  end

  def build(url)
    @providers.each do |provider|
      MyUtils.pinfo "Checking if provider '#{provider}' can handle the URL..."
      provider_built = provider.new(url)
      return provider_built if provider_built.valid and provider_built.is_a?(Provider)

      MyUtils.pinfo "Provider '#{provider}' can not handle the URL"
    end
    raise NoProviderError, 'The given URL is not supported by any provider'
  end
end
