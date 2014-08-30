require 'open-uri'
begin
  require 'nokogiri'
  NOKOGIRI_AVAIL = true
rescue LoadError
  NOKOGIRI_AVAIL = false
end

##
# Performs polling to GitHub's user page to check for long streaks

module GithubStats
  module LongStreakPoller
    def poll_longer_streak
      return unless NOKOGIRI_AVAIL
      page = open("https://github.com/#{@name}")
      element = Nokogiri::HTML(page.read).css('.contrib-streak-current').first
      streak = element.text.split[2].to_i
      patch_streak(streak) if streak > @data.streak.size
    end

    def patch_streak(new)
      new_streak = StreakInjector.new
      new_streak.override_streak new
      @data.instance_variable_set(:@github_streak, new_streak)
      @data.instance_eval "def streak\n@github_streak\nend"
      @data.instance_eval "def longest_streak\n@github_streak\nend"
    end
  end

  class StreakInjector < Array
    def override_streak(new)
      @streak_length = new
    end

    def size
      @streak_length
    end

    alias_method :length, :size
  end
end
