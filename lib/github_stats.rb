require 'curb'
require 'json'
require 'date'

begin
    require 'rugged'
    Using_Rugged = true
rescue LoadError
    Using_Rugged = false
end

begin
    require 'basic_cache'
    Using_Cache = true
rescue LoadError
    Using_Cache = false
end

module Github_Stats
    Version = '0.0.5'

    class << self
        def new(*args)
            self::Contributions.new(*args)
        end
    end

    Datapoint = Struct.new(:date, :score)

    class Contributions
        attr_reader :user, :data, :last_updated
        attr_accessor :url

        def initialize(user = nil, autoload=true)
            @user = user || guess_user
            @url = "https://github.com/users/#@user/contributions_calendar_data"
            @data = []
            @last_updated = nil
            @cache = Using_Cache ? Basic_Cache.new : Github_Stats::Null_Cache.new
            update if autoload
        end

        def inspect
            to_s
        end

        def to_s
            "Contributions from #@user"
        end

        def to_a
            @data
        end

        def to_h
            @data.inject(Hash.new(0)) { |hash, point| hash[point.date] = point.score ; hash }
        end

        def guess_user
            names = []
            names << Rugged::Config.global['github.user'] if Using_Rugged
            names << ENV['USER']

            names.reject! {|name| name.nil? }
            names.length ? names.first : (raise "Failed to guess username")
        end

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

        def today
            @cache.cache { to_h[Date.today] }
        end

        def streak
            @cache.cache { @data.reverse.take_while{ |point| point.score > 0 } }
        end

        def longest_streak
            @cache.cache do
                @data.inject(Array.new(1, [])) do |streaks, point|
                    point.score == 0 ? streaks << [] : streaks.last << point ; streaks
                end.max {|a, b| a.length <=> b.length}
            end
        end

        def max
            @cache.cache { @data.max { |a, b| a.score <=> b.score } }
        end

        def quartile_boundaries
            @cache.cache do
                range = @data.map{ |p| p.score }.uniq.sort.select{ |s| not s.zero? }
                [0, *(1..3).map { |q| range[ (q * range.length / 4) - 2 ] }, range.last]
            end
        end

        def quartiles
            @cache.cache do
                bounds = quartile_boundaries
                groups = Array.new(5) { Array.new }
                @data.inject(groups) { |acc, point| acc[bounds.find_index{ |i| point.score <= i }] << point ; acc }
            end
        end
    end

    class Null_Cache
        def clear
        end

        def cache(key = nil, &code)
            code.call
        end
    end
end

