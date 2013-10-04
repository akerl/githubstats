##
# This module provides a consumable object based on Github's contribution stats

require 'curb'
require 'json'
require 'date'

##
# Rugged is used to check git's configuration for a github user, if available

begin
    require 'rugged'
    Using_Rugged = true
rescue LoadError
    Using_Rugged = false
end

##
# Basic_Cache is used to cache computation results, if available

begin
    require 'basic_cache'
    Using_Cache = true
rescue LoadError
    Using_Cache = false
end

module Github_Stats
    Version = '0.0.9'

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

        ##
        # Create a new object
        # Guesses the user if one is not supplied
        # Automatically updates if not disabled
        # Creates a new cache object

        def initialize(user = nil, autoload=true)
            @user = user || guess_user
            @url = "https://github.com/users/#@user/contributions_calendar_data"
            @data = []
            @last_updated = nil
            @cache = Using_Cache ? Basic_Cache.new : Github_Stats::Null_Cache.new
            update if autoload
        end

        ##
        # Print human-readable string about object

        def to_s
            "Contributions from #@user"
        end
        alias :inspect :to_s

        ##
        # Return raw data directly

        def to_a
            @data
        end

        ##
        # Return Hash where keys are dates and values are scores

        def to_h
            @data.inject(Hash.new(0)) { |hash, point| hash[point.date] = point.score ; hash }
        end

        ##
        # Try to guess username
        # Checks Rugged if available, then ENV['USER']

        def guess_user
            names = []
            names << Rugged::Config.global['github.user'] if Using_Rugged
            names << ENV['USER']

            names.reject! {|name| name.nil? }
            names.length ? names.first : (raise "Failed to guess username")
        end

        ##
        # Update the data based on Github

        def update
            begin
                raw_data = JSON.parse Curl::Easy.perform(@url).body_str
            rescue
                raise 'Unable to load data from GitHub'
            end
            begin
                new_data = raw_data.collect { |date, score| Datapoint.new(Date::parse(date), score.to_i) }
            rescue
                raise "Failed to parse data"
            end
            @data = new_data
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
            @cache.cache { @data.reverse.take_while{ |point| point.score > 0 } }
        end

        ##
        # Return the longest streak

        def longest_streak
            @cache.cache do
                @data.inject(Array.new(1, [])) do |streaks, point|
                    point.score == 0 ? streaks << [] : streaks.last << point ; streaks
                end.max {|a, b| a.length <=> b.length}
            end
        end

        ##
        # Return the highest score in the dataset

        def max
            @cache.cache { @data.max { |a, b| a.score <=> b.score } }
        end

        ##
        # Return the break-points between the quartiles

        def quartile_boundaries
            @cache.cache do
                range = @data.map{ |p| p.score }.uniq.sort.select{ |s| not s.zero? }
                (1..3).map { |q| range[(q * range.length / 4) - 2] }.unshift(0).push(range.last)
            end
        end

        ##
        # Return the quartiles

        def quartiles
            @cache.cache do
                bounds = quartile_boundaries
                groups = Array.new(5) { Array.new }
                @data.inject(groups) { |acc, point| acc[bounds.find_index{ |i| point.score <= i }] << point ; acc }
            end
        end

        def quartile(score)
            bounds = quartile_boundaries
            return nil if score > quartile_boundaries.last or score < 0
            bounds.count { |bound| score > bound }
        end
    end

    ##
    # The Null_Cache is used if Basic_Cache is not available
    # As per the name, it does not cache anything

    class Null_Cache

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

