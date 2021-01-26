#!/usr/bin/env ruby

require_relative 'git'
require_relative 'strict_http'

class NoProviderError < StandardError; end

class ScraperError < StandardError; end

module Scraper
  attr_reader :valid, :changelog, :host

  def initialize(*)
    @supported = {}
    @valid = false
  end

  def supports?(url)
    if url.host.include? @host
      @supported.each do |expression, type|
        MyUtils.pinfo("#{@name}: Checking if changelog pattern '#{expression}' supports this URL...")
        next unless expression.match?(url.request_uri)

        MyUtils.pinfo("#{@name}: Changelog pattern '#{expression}' supports this URL")
        @valid = true
        @req_url = url
        @changelog_type = type
        break
      end
    end
    MyUtils.pinfo("#{self.class} scraper supports '#{url}'") if @valid
    @valid
  end

  def build_from(url)
    grab_html(url) if @valid
    MyUtils.pinfo("Scraping a #{@name} #{@changelog_type}...") if @valid
    begin
      scraped = scrape if @valid
    rescue StandardError
      raise(NotImplementedError, 'Scraping failed, this may be due to a malformed URL or outdated scraper')
    end
    raise(ScraperError, 'The scraper rejected the provided URL') unless scraped

    MyUtils.pinfo("#{@name}: Scraping succeeded")
    @dom = nil
  end

  private

  def grab_html(url)
    MyUtils.pinfo("#{@name}: Downloading the webpage...")
    @dom = Nokogiri::HTML(StrictHTTP.strict_get(url, HTTP_TIMEOUT_SECONDS).to_s)
    MyUtils.pinfo("#{@name}: Webpage downloaded successfully")
  end

  def scrape()
    raise(NotImplementedError, "Please create a scraper that inherits from #{Provider} and implement 'scrape()'")
  end

  def first_line(line)
    line.strip.split("\n").first
  end
end

module ProviderFactory
  @scrapers = []
  class << self
    attr_reader :scrapers

    def scrapers=(scraper)
      raise(ArgumentError, "The #{ProviderFactory} only accepts #{Scraper} subclasses") unless scraper < Scraper

      @scrapers << scraper
    end

    def build(url)
      @scrapers.each do |scraper|
        MyUtils.pinfo("Checking if scraper '#{scraper}' can handle the provided URL...")
        scraper_built = scraper.new
        return scraper_built if scraper_built.supports?(url)

        MyUtils.pinfo("Scraper '#{scraper}' can not handle the provided URL")
      end
      raise(NoProviderError, "There is no #{Scraper} that can handle '#{url}'")
    end

    def hosts()
      @scrapers.reduce([]) do |accumulator, current|
        accumulator << current.new.host
      end
    end
  end
end

require_relative 'scrapers'
