#!/usr/bin/env ruby

# - if you want to extend the functionality, add more providers here and don't forget to also add them to the factory -

class GitHub
  include Provider
  def initialize(url)
    super
    @host = 'github.com'
    @name = 'GitHub'
    @supported[:pull] = MergeRequest
    build_provider(url)
  end

  private

  # Because of how Nokogiri works, scrape methods may trigger Metric/AbcSize hint due to chained calls
  def scrape_pull_request
    puts "MR TITLE: #{@dom.css('.gh-header-title span').first.children.text}"
    puts "MR ID => #{@dom.css('.gh-header-title span').last.children.text}"
    puts "MR Status => #{@dom.css('.gh-header-meta span').first.text}"
    puts "MR Base => #{@dom.css('.commit-ref a').first.attributes['title'].value}"
    puts "MR Dest => #{@dom.css('.commit-ref a').last.attributes['title'].value}"
    puts "MR Author => #{@dom.css('.timeline-comment-header-text .author').first.text}"
    puts "PR Time => #{@dom.css('.timeline-comment-header-text relative-time').first.attributes['datetime'].value}"
    @dom.css('.js-commit-group-commits .pr-1 code a.link-gray').each do |commit|
      puts "\tCommit Title => #{first_line(commit.attributes['title'].value)}"
      puts "\tCommit Hash => #{commit.attributes['href'].value.split('/').last}"
    end
  end

  def scrape()
    @changelog = @changelog_type.new
    case @changelog
    when MergeRequest
      scrape_pull_request
    else
      false
    end
  end
end
