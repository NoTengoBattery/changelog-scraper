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
    header = @dom.css('.gh-header-title span')
    branches = @dom.css('.commit-ref a')
    title = @dom.css('.timeline-comment-header-text')
    @changelog.subject = header.first.text.strip
    @changelog.id = header.last.text.strip
    @changelog.time = title.css('relative-time').attribute('datetime').value.strip
    @changelog.author = title.css('.author').text.strip
    @changelog.url = @req_url
    @changelog.status = @dom.css('.gh-header-meta div span').first.text.strip
    @changelog.target_branch = branches.first.attribute('title').value.strip
    @changelog.base_branch = branches.last.attribute('title')&.value&.strip
    @changelog.base_branch = @changelog.base_branch.nil? ? '[deleted branch]' : @changelog.base_branch
  end

  def scrape_pull_commits
    url = URI.parse("#{@changelog.url}/commits")
    commits = Nokogiri::HTML(StrictHTTP.strict_get(url, HTTP_TIMEOUT_SECONDS).to_s)
    commits.css('li.js-commits-list-item').each do |commit_html|
      commit = Commit.new
      commit.subject = commit_html.css('a.js-navigation-open').text.strip
      commit.id = commit_html.css('a.text-mono').text.strip
      commit.message = commit_html.css('pre').text.strip
      commit.author = commit_html.css('.commit-author').text.strip
      commit.time = commit_html.css('relative-time').attribute('datetime').value.strip
      commit.url = URI.parse("#{@base_url}#{commit_html.css('a.text-mono').attribute('href').value}")
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
