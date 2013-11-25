require 'basiccache'
require 'date'

##
# Definition of data objects for GithubStats

module GithubStats
  ##
  # This is the magic constant used for determining outliers

  GH_MAGIC = 3.77972616981

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
                      :mean, :std_var, :quartile_boundaries, :quartiles,
                      :quartile]
    end

    def to_h
      @raw.reduce(Hash.new(0)) { |a, e| a.merge(e.date => e.score) }
    end

    def today
      to_h[Date.today]
    end

    def streaks
      streaks = @raw.reduce(Array.new(1, [])) do |acc, point|
        point.score == 0 ? acc << [] : acc.last << point
        acc
      end
      streaks.first.empty? ? streaks[1..-1] : streaks
    end

    def longest_streak
      streaks.max { |a, b| a.length <=> b.length }
    end

    def streak
      streaks.last.last.date >= Date.today - 1 ? streaks.last : []
    end

    def max
      @raw.max { |a, b| a.score <=> b.score }
    end

    def mean
      @raw.reduce(0) { |a, e| a + e.score } / @raw.size.to_f
    end

    def std_var
      first_pass = @raw.reduce(0) { |a, e| (e.score.to_f - mean)**2 + a }
      Math.sqrt(first_pass / (@raw.size - 1))
    end

    def quartile_boundaries
      data = @raw.map { |p| p.score }.uniq.sort.select { |s| !s.zero? }
      data.select! { |x| (mean - x).abs / std_var <= GH_MAGIC }
      [0, *(1..3).map { |q| data[(q * data.length / 4) - 2] }, max.score]
    end

    def quartiles
      @data.reduce(Array.new(5) { Array.new }) do |acc, point|
        acc[quartile_boundaries.find_index { |i| point.score <= i }] << point
      end
    end

    def quartile
      return nil if score > quartile_boundaries.last || score < 0
      bounds.count { |bound| score > bound }
    end
  end
end
