require 'curb'
require 'json'
require 'date'

module Contributions
    class << self
        def new(*args)
            self::Contributions.new(*args)
        end
    end

    Datapoint = Struct.new(:date, :score)

    class Contributions
        attr_reader :user, :data, :last_updated
        attr_accessor :url

        def initialize(user, autoload=true)
            @user = user
            @url = "https://github.com/users/#@user/contributions_calendar_data"
            @data = []
            @last_updated = nil
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
        end

        def today
            to_h[Date.today]
        end

        def streak
            @data.reverse.take_while{ |point| point.score > 0 }
        end

        def max
            @data.max { |a, b| a.score <=> b.score }
        end
    end
end

