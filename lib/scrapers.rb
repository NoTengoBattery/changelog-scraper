#!/usr/bin/env ruby

# - if you want to extend the functionality, add more providers here and don't forget to also add them to the factory -
# - because of how `nokogiri` works, scrape methods may trigger Metric/AbcSize hint due to chained calls -

class GitHubScraper
  include Scraper
  def initialize
    super
    @host = 'github.com'
    @base_url = 'https://github.com'
    @name = 'GitHub'
    @supported[:pull] = MergeRequest
  end

  private

  def scrape_pull_request # rubocop:disable Metric/AbcSize, Metrics/MethodLength
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
    @dom.css('.js-commit-group-commits .pr-1 code a.link-gray').each do |commit_html|
      commit = Commit.new
      url = URI.parse("#{@base_url}#{commit_html.attributes['href'].value}")
      commit_dom = Nokogiri::HTML(StrictHTTP.strict_get(url, HTTP_TIMEOUT_SECONDS).to_s)
      commit.subject = commit_dom.css('.commit-title').first.children.text.strip
      commit.id = commit_dom.css('.sha').first.children.text.strip
      commit.time = commit_dom.css('relative-time').last.attributes['datetime'].value
      message = commit_dom.css('.commit-desc pre')
      commit.message = message.first.children.text.strip unless message
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
    else
      scraped = false
    end
    scraped
  end
end
ProviderFactory.scrapers = GitHubScraper
