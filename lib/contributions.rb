require 'curb'
require 'json'
require 'date'

module Contributions
    class << self
        def new(*args)
            self::User.new(*args)
        end
    end

    class User
        attr_reader :user, :data
        attr_accessor :url

        def initialize(user, autoload=true)
            @user = user
            @url = "https://github.com/users/#@user/contributions_calendar_data"
            @data = Contributions::Data.new
            update if autoload
        end

        def inspect
            to_s
        end

        def to_s
            "Contributions from #@user"
        end

        def update
            begin
                tmp = JSON.parse Curl::Easy.perform(@url).body_str
            rescue
                raise 'Unable to load data from GitHub'
            end
            @data.update(tmp)
        end
    end

    class Data
        attr_reader :raw, :last_updated

        def initialize
            @raw = []
            @last_updated = nil
        end

        def update(new_data)
            begin
                data = new_data.collect { |date, score| [Date::parse(date), score.to_i] }
                timestamp = DateTime.now
            rescue
                raise "Failed to parse data"
            end
            @raw = data
            @last_updated = timestamp
        end

        def inspect
            to_s
        end

        def to_s
            "Contribution data from #@last_updated"
        end

        def to_h
            @raw.inject(Hash.new(0)) { |hash, (date, score)| hash[date] = score }
        end

        def to_a
            @raw
        end

        def today?
            @raw.to_h[Date.today]
        end
    end
end

