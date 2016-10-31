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
    alias to_a raw

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
      @raw.reduce(Hash.new(0)) do |acc, elem|
        acc.merge(elem.date => elem.score)
      end
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
      @raw.map(&:score)
    end

    ##
    # All streaks for a user

    def streaks
      streaks = @raw.each_with_object(Array.new(1, [])) do |point, acc|
        point.score.zero? ? acc << [] : acc.last << point
      end
      streaks.reject!(&:empty?)
      streaks
    end

    ##
    # The longest streak

    def longest_streak
      return [] if streaks.empty?
      streaks.max { |a, b| a.length <=> b.length }
    end

    ##
    # The current streak, or nil

    def streak
      return [] if streaks.empty?
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
      first_pass = @raw.reduce(0) do |acc, elem|
        (elem.score.to_f - mean)**2 + acc
      end
      Math.sqrt(first_pass / (@raw.size - 1))
    end

    ##
    # Outliers of the set

    def outliers
      return [] if scores.uniq.size < 5
      scores.select { |x| ((mean - x) / std_var).abs > GITHUB_MAGIC }.uniq
    end

    ##
    # Outliers as calculated by GitHub
    # They only consider the first 3 or 1, based on the mean and max of the set

    def gh_outliers
      outliers.take(6 > max.score - mean || 15 > max.score ? 1 : 3)
    end

    ##
    # The boundaries of the quartiles
    # The index represents the quartile number
    # The value is the upper bound of the quartile (inclusive)

    def quartile_boundaries # rubocop:disable Metrics/AbcSize
      top = scores.reject { |x| gh_outliers.include? x }.max
      range = (1..top).to_a
      range = [0] * 3 if range.empty?
      mids = (1..3).map do |q|
        index = q * range.size / 4 - 1
        range[index]
      end
      bounds = (mids + [max.score]).uniq.sort
      [0] * (5 - bounds.size) + bounds
    end

    ##
    # Return the list split into quartiles

    def quartiles
      quartiles = Array.new(5) { [] }
      @raw.each_with_object(quartiles) do |elem, acc|
        acc[quartile(elem.score)] << elem
      end
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
      data = _pad data, 0, fill_value, 0
      _pad data, -1, fill_value, 6
    end

    private

    def _pad(data, index, fill_value, goal)
      mod = index * -2 - 1 # 0 index moves -1 in time, -1 move +1 in time
      point = GithubStats::Datapoint
      until data[index].date.wday == goal
        data.insert index, point.new(data[index].date + mod, fill_value)
      end
      data
    end
  end
end
