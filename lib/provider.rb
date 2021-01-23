#!/usr/bin/env ruby

require_relative 'git'
require_relative 'http'

class NoProviderError < StandardError; end

class NoProviderHandlerError < NoProviderError; end

class ScraperError < StandardError; end

module Provider
  attr_reader :valid

  def initialize(*)
    @supported = {}
  end

  private

  def url_validator(url)
    provider = self.class
    if url.host == @host
      @supported.each do |key, val|
        MyUtils.pinfo("#{provider}: Checking if changelog type '#{key}' supports this URL...")
        next unless url.request_uri.include? key.to_s

        MyUtils.pinfo("#{provider}: Changelog type '#{key}' supports this URL")
        @valid = true
        @req_url = url
        @changelog_type = val
        break
      end
      raise(NoProviderHandlerError, "The URL is a malformed #{@name} webpage and can not be handled") unless @valid
    end
    @valid
  end

  def get_html(url)
    MyUtils.pinfo('Downloading the webpage...')
    @dom = Nokogiri::HTML(StrictHTTP.strict_get(url).to_s)
    MyUtils.pinfo('Webpage downloaded successfully')
  end

  def scrape()
    raise(NotImplementedError, "Please create a provider that inherits from #{Provider} and implement `scrape`")
  end

  def first_line(line)
    line.strip.split("\n").first
  end

  def build_provider(url)
    url_validator(url)
    return unless @valid

    get_html(url) if @valid
    MyUtils.pinfo("Scraping a #{@name} #{@changelog_type.name}...") if @valid
    begin
      scraped = scrape if @valid
    rescue StandardError
      raise(ScraperError, 'Scraping failed, this may be due to a malformed URL or outdated scraper')
    end
    raise(ScraperError, 'The scraper rejected the provided URL') unless scraped

    MyUtils.pinfo("#{@name}: Scraping succeeded")
    @dom = nil
  end
end

require_relative 'scrapers'

# Add new providers here by pushing the class into the @providers array. Do not modify anything else.
class ProviderFactory
  def initialize
    @providers = []
    @providers << GitHubScraper
  end

  def build(url)
    @providers.each do |provider|
      MyUtils.pinfo("Checking if provider '#{provider}' can handle the URL...")
      provider_built = provider.new(url)
      return(provider_built) if provider_built.valid and provider_built.is_a?(Provider)

      MyUtils.pinfo("Provider '#{provider}' can not handle the URL")
    end
    raise(NoProviderError, 'The given URL is not supported by any provider')
  end
end
