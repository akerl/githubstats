# frozen_string_literal: true
require 'curb'
require 'json'
require 'nokogiri'

##
# Rugged is used if available to look up the user's Github username

begin
  require 'rugged'
  USE_RUGGED = true
rescue LoadError
  USE_RUGGED = false
end

##
# Definitions of user objects for GithubStats
module GithubStats
  ##
  # Helper method for creating new user objects

  def self.new(*args)
    self::User.new(*args)
  end

  ##
  # Default host for grabbing data

  DEFAULT_HOST = (ENV['GITHUB_URL'] || 'https://github.com').freeze

  ##
  # Default URL for grabbing data

  DEFAULT_URL = "#{DEFAULT_HOST}/users/%s/contributions".freeze

  ##
  # User object
  class User
    attr_reader :name, :url, :data, :last_updated

    ##
    # Creates a new user object

    def initialize(params = {})
      params = { name: params } unless params.is_a? Hash
      @name = params[:name] || guess_user
      @url = (params[:url] || DEFAULT_URL) % @name
      @last_updated = nil
    end

    ##
    # Print human-readable string about object

    def to_s
      "Contributions from #{@name}"
    end
    alias inspect to_s

    ##
    # Set a custom streak that takes into account GitHub,
    # which reports full length but only gives data for a year

    def streak
      naive = data.streak
      return naive if naive.size < 365
      [-1] * (real_streak_length - naive.size) + naive
    end

    ##
    # Set a custom longest_streak to account for the overriden streak

    def longest_streak
      return data.longest_streak if data.longest_streak.size < 365
      streak
    end

    ##
    # Lazy loader for data

    def data(reload = false)
      load_data if reload == true || @last_updated.nil?
      @data
    end

    ##
    # Adjust respond_to? to properly respond with patched method_missing

    def respond_to?(method, include_private = false)
      load_data if @last_updated.nil?
      super || @data.respond_to?(method, include_private)
    end

    private

    ##
    # Guesses the user's name based on system environment

    def guess_user(names = [])
      names << Rugged::Config.global['github.user'] if USE_RUGGED
      names << ENV['USER']
      names.find { |name| name } || (raise 'Failed to guess username')
    end

    ##
    # Creates a new Data object from downloaded data

    def load_data
      @data = GithubStats::Data.new download
      @last_updated = DateTime.now
    end

    ##
    # Set a custom longest_streak that takes into account GitHub,
    # which reports full length but only gives data for a year

    def real_streak_length
      url = @url.split('/users/').first + '/' + @name
      data = Curl::Easy.perform(url).body_str
      Nokogiri::HTML(data).css('.contrib-number').last.text.split.first.to_i
    end

    ##
    # Downloads new data from Github

    def download
      svg = Curl::Easy.perform(@url).body_str
      html = Nokogiri::HTML(svg)
      html.css('.day').map do |x|
        x.attributes.values_at('data-date', 'data-count').map(&:value)
      end
    rescue
      raise 'Unable to load data from Github'
    end

    def method_missing(sym, *args, &block)
      load_data if @last_updated.nil?
      return super unless @data.respond_to? sym
      define_singleton_method(sym) { |*a, &b| @data.send(sym, *a, &b) }
      send(sym, *args, &block)
    end
  end
end

require 'githubstats/version'
require 'githubstats/data'
