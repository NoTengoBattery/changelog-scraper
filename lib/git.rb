#!/usr/bin/env ruby

class GitMessage
  attr_reader :time, :url
  attr_accessor :subject, :id, :message, :author, :name

  def initialize(name = 'Message')
    @name = name
  end

  def url=(uri)
    uri.is_a?(URI) ? (@url = uri) : raise(ArgumentError, "Expected an object of type #{URI}")
  end

  def time=(time)
    case time
    when Time
      @time = time
    when String, Numeric
      @time = Time.parse(time)
    else
      raise(ArgumentError, "Expected a #{Time} object, a convertible #{String}, or a #{Numeric} value")
    end
  end
end

class Commit < GitMessage
  def initialize(name = 'Commit')
    super
  end
end

class Changelog < GitMessage
  attr_reader :commits

  def initialize(name = 'Changelog')
    super
    @commits = []
  end

  def commits=(commit)
    commit.is_a?(Commit) ? (@commits << commit) : raise(ArgumentError, "Expected an object of type #{Commit}")
  end
end

class MergeRequest < Changelog
  def initialize(name = 'Merge Request')
    super
  end
  attr_accessor :status, :target_branch, :base_branch
end
