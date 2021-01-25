#!/usr/bin/env ruby

class GitMessage
  attr_reader :time, :url
  attr_accessor :subject, :id, :message, :author, :name

  def initialize(name = 'git message')
    @name = name
  end

  def url=(uri)
    uri.is_a?(URI) ? (@url = uri) : raise(ArgumentError, "Expected an object of type #{URI}")
  end

  def time=(time)
    @time = time.is_a?(Time) ? time : Time.parse(time)
  end
end

class Commit < GitMessage
  def initialize(name = 'commit')
    super
  end
end

class Changelog < GitMessage
  attr_reader :commits

  def initialize(name = 'changelog')
    super
    @commits = []
  end

  def commits=(commit)
    commit.is_a?(Commit) ? (@commits << commit) : raise(ArgumentError, "Expected an object of type #{Commit}")
  end
end

class MergeRequest < Changelog
  def initialize(name = 'merge request')
    super
  end
  attr_accessor :status, :target_branch, :base_branch
end
