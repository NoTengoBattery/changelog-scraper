#!/usr/bin/env ruby

# - implement new printers here, and send the class to the factory using `PrinterFactory.printers = [class]`

class GitHubScraper
  include Scraper

  def initialize
    super
    @host = 'github.com'
    @base_url = 'https://github.com'
    @name = 'GitHub'
    @supported[%r{pull/\d+/?$}] = MergeRequest
  end

  private

  def scrape_pull_request
    title = @dom.css('.gh-header-title span')
    branches = @dom.css('.commit-ref a')
    base = branches.last.attributes['title']
    @changelog.subject = title.first.children.text.strip
    @changelog.id = title.last.children.text.strip
    @changelog.time = @dom.css('.timeline-comment-header-text relative-time').first.attributes['datetime'].value
    @changelog.author = @dom.css('.timeline-comment-header-text .author').first.text.strip
    @changelog.url = @req_url
    @changelog.status = @dom.css('.gh-header-meta span').first.text.strip
    @changelog.target_branch = branches.first.attributes['title'].value.strip
    @changelog.base_branch = base.value.strip unless base.nil?
  end

  def scrape_pull_commits # rubocop:disable Metrics/AbcSize
    url = URI.parse("#{@changelog.url}/commits")
    commits = Nokogiri::HTML(StrictHTTP.strict_get(url, HTTP_TIMEOUT_SECONDS).to_s)
    commits.css('.js-commits-list-item div a.text-bold').each do |commit_html|
      commit = Commit.new
      url = URI.parse("#{@base_url}#{commit_html.attributes['href'].value}".gsub(%r{pull/\d+/?/commits}, 'commit'))
      commit_dom = Nokogiri::HTML(StrictHTTP.strict_get(url, HTTP_TIMEOUT_SECONDS).to_s)
      commit.subject = commit_dom.css('.commit-title').first.children.text.strip
      commit.id = commit_dom.css('.sha').first.children.text.strip
      commit.time = commit_dom.css('relative-time').last.attributes['datetime'].value
      message = commit_dom.css('.commit-desc pre')
      commit.message = message.first.children.text.strip unless message.empty?
      commit.author = commit_dom.css('.commit-author').first.children.text.strip
      commit.url = url
      @changelog.commits = commit
    end
  end

  def scrape()
    @changelog = @changelog_type.new
    scraped = true
    case @changelog
    when MergeRequest
      @changelog.name = 'Pull Request'
      scrape_pull_request
      scrape_pull_commits
    else
      scraped = false
    end
    scraped
  end
end
ProviderFactory.scrapers = GitHubScraper
