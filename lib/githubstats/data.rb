require 'basiccache'
require 'date'

##
# Definition of data objects for GithubStats
module GithubStats
  ##
  # This is the magic constant used for determining outliers

  GITHUB_MAGIC = 3.77972616981

  ##
  # Helper struct for defining datapoints

  Datapoint = Struct.new(:date, :score)

  ##
  # Data class for calculations
  class Data
    ##
    # MethodCacher provides computation caching

    include MethodCacher

    attr_reader :raw
    alias_method :to_a, :raw

    ##
    # Create a data object and turn on caching

    def initialize(data)
      @raw = data.map { |d, s| Datapoint.new(Date.parse(d), s.to_i) }
      enable_caching [:to_h, :today, :streaks, :longest_streak, :streak, :max,
                      :mean, :std_var, :quartile_boundaries, :quartiles]
    end

    ##
    # The data as a hash where the keys are dates and values are scores

    def to_h
      @raw.reduce(Hash.new(0)) { |a, e| a.merge(e.date => e.score) }
    end

    ##
    # The score for today

    def today
      to_h[Date.today]
    end

    ##
    # The score for a given day

    def [](date)
      to_h[Date.parse(date)]
    end

    ##
    # Scores in chronological order

    def scores
      @raw.map { |x| x.score }
    end

    ##
    # All streaks for a user

    def streaks
      streaks = @raw.reduce(Array.new(1, [])) do |acc, point|
        point.score == 0 ? acc << [] : acc.last << point
        acc
      end
      streaks.reject! { |s| s.empty? }
      streaks
    end

    ##
    # The longest streak

    def longest_streak
      return nil if streaks.empty?
      streaks.max { |a, b| a.length <=> b.length }
    end

    ##
    # The current streak, or nil

    def streak
      return nil if streaks.empty?
      streaks.last.last.date >= Date.today - 1 ? streaks.last : []
    end

    ##
    # The highest scoring day

    def max
      @raw.max { |a, b| a.score <=> b.score }
    end

    ##
    # The mean score

    def mean
      scores.reduce(:+) / @raw.size.to_f
    end

    ##
    # The standard variance (two pass)

    def std_var
      first_pass = @raw.reduce(0) { |a, e| (e.score.to_f - mean)**2 + a }
      Math.sqrt(first_pass / (@raw.size - 1))
    end

    ##
    # Outliers of the set

    def outliers
      return [] if scores.uniq.size < 5
      scores.select { |x| ((mean - x) / std_var).abs > GITHUB_MAGIC }.uniq
    end

    ##
    # The boundaries of the quartiles
    # The index represents the quartile number
    # The value is the upper bound of the quartile (inclusive)

    def quartile_boundaries
      range = (0..scores.reject { |x| outliers.take(3).include? x }.max).to_a
      [0, *(1..3).map { |q| range[(q * range.size / 4) - 1] }, max.score]
    end

    ##
    # Return the list split into quartiles

    def quartiles
      quartiles = Array.new(5) { [] }
      @raw.reduce(quartiles) { |a, e| a[quartile(e.score)] << e && a }
    end

    ##
    # Return the quartile of a given score

    def quartile(score)
      return nil if score < 0 || score > max.score
      quartile_boundaries.count { |bound| score > bound }
    end

    ##
    # Pad the dataset to full week increments

    def pad(fill_value = -1, data = @raw.clone)
      point = GithubStats::Datapoint
      until data.first.date.wday == 0
        data.unshift point.new(data.first.date - 1, fill_value)
      end
      until data.last.date.wday == 6
        data << point.new(data.last.date + 1, fill_value)
      end
      data
    end
  end
end
