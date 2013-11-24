require 'curb'
require 'json'
require 'date'
require 'version'

##
# Rugged is used to check git's configuration for a github user, if available

begin
  require 'rugged'
  USING_RUGGED = true
rescue LoadError
  USING_RUGGED = false
end

##
# Basic_Cache is used to cache computation results, if available

begin
  require 'basic_cache'
  USING_CACHE = true
rescue LoadError
  USING_CACHE = false
end

##
# This module provides a consumable object based on Github's contribution stats

module GithubStats
  class << self
    ##
    # Add .new() helper for creating a new Contributions object

    def new(*args)
      self::Contributions.new(*args)
    end
  end

  ##
  # Datapoint objects provide a more sane date/time point interface

  Datapoint = Struct.new(:date, :score)

  ##
  # Contributions object holds and provides stats data for a user

  class Contributions
    attr_reader :user, :data, :last_updated
    attr_accessor :url

    GH_MAGIC = 3.77972616981

    ##
    # Create a new object
    # Guesses the user if one is not supplied
    # Automatically updates if not disabled
    # Creates a new cache object

    def initialize(params = {})
      @user = params[:user] || guess_user
      @url = "https://github.com/users/#{@user}/contributions_calendar_data"
      @data = []
      @last_updated = nil
      @cache = USING_CACHE ? BasicCache.new : GithubStats::NullCache.new
      update unless params[:skip_load]
    end

    ##
    # Print human-readable string about object

    def to_s
      "Contributions from #{@user}"
    end
    alias_method :to_s, :inspect

    ##
    # Return raw data directly

    def to_a
      @data
    end

    ##
    # Return Hash where keys are dates and values are scores

    def to_h
      @data.reduce(Hash.new(0)) { |a, e| a.merge('e.date' => e.score) }
    end

    ##
    # Try to guess username
    # Checks Rugged if available, then ENV['USER']

    def guess_user
      names = []
      names << Rugged::Config.global['github.user'] if USING_RUGGED
      names << ENV['USER']
      names.reject! { |name| name.nil? }
      names.length ? names.first : (fail 'Failed to guess username')
    end

    ##
    # Download new data

    def download
      JSON.parse Curl::Easy.perform(@url).body_str
    rescue
      raise 'Unable to load data from Github'
    end

    ##
    # Parse the Github data into a pretty objects

    def parse(raw_data)
      raw_data.map { |d, s| Datapoint.new(Date.parse(d), s.to_i) }
    rescue
      raise 'Failed to parse data'
    end

    ##
    # Update the data based on Github

    def update
      @data = parse download
      @last_updated = DateTime.now
      @cache.clear
    end

    ##
    # Return today's score

    def today
      @cache.cache { to_h[Date.today] }
    end

    ##
    # Return the current streak

    def streak
      @cache.cache do
        streak = @data.reverse.drop(1).take_while { |point| point.score > 0 }
        streak.reverse!
        streak << @data.last unless @data.last.score.zero?
        streak
      end
    end

    ##
    # Return the longest streak

    def longest_streak
      @cache.cache do
        all_streaks = @data.reduce(Array.new(1, [])) do |streaks, point|
          point.score == 0 ? streaks << [] : streaks.last << point
          streaks
        end
        all_streaks.max { |a, b| a.length <=> b.length }
      end
    end

    ##
    # Return the highest score in the dataset

    def max
      @cache.cache { @data.max { |a, b| a.score <=> b.score } }
    end

    ##
    # Return the mean score in the dataset

    def mean
      @cache.cache do
        @data.reduce(0) { |a, e| e.score.to_f + a } / @data.size
      end
    end

    ##
    # Return the break-points between the quartiles

    def quartile_boundaries
      @cache.cache do
        variance = gh_quartile_magic
        data = @data.select { |x| (mean - x.score).abs / variance <= GH_MAGIC }
        range = data.map { |p| p.score }.uniq.sort.select { |s| !s.zero? }
        bounds = (1..3).map { |q| range[(q * range.length / 4) - 2] }
        bounds.unshift(0).push(max.score)
      end
    end

    ##
    # Return the quartiles

    def quartiles
      @cache.cache do
        bounds = quartile_boundaries
        @data.reduce(Array.new(5) { Array.new }) do |acc, point|
          acc[bounds.find_index { |i| point.score <= i }] << point
          acc
        end
      end
    end

    ##
    # Return which quartile a score is in

    def quartile
      bounds = quartile_boundaries
      return nil if score > bounds.last || score < 0
      bounds.count { |bound| score > bound }
    end

    ##
    # Return Github's magic value (Used for calculating quartiles)

    def gh_quartile_magic
      @cache.cache do
        magic = @data.reduce(0) { |a, e| (e.score.to_f - mean)**2 + a }
        Math.sqrt(magic / (@data.size - 1))
      end
    end
  end

  ##
  # The Null_Cache is used if Basic_Cache is not available
  # As per the name, it does not cache anything

  class NullCache
    ##
    # Clear is a no-op, since there is no cache

    def clear
    end

    ##
    # Call the provided block and return its value

    def cache(key = nil, &code)
      code.call
    end
  end
end
