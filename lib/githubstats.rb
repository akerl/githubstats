require 'curb'
require 'json'

##
# Rugged is used if available to look up the user's Github username

begin
  require 'rugged'
  RUGGED_USER = Rugged::Config.global['github.user']
rescue LoadError
  RUGGED_USER = nil
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
  # Default URL for grabbing data

  DEFAULT_URL = 'https://github.com/users/%s/contributions_calendar_data'

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
    alias_method :inspect, :to_s

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
      names << RUGGED_USER
      names << ENV['USER']
      names.find { |name| !name.nil? } || (fail 'Failed to guess username')
    end

    ##
    # Creates a new Data object from downloaded data

    def load_data
      @data = GithubStats::Data.new download
      @last_updated = DateTime.now
    end

    ##
    # Downloads new data from Github

    def download
      JSON.parse Curl::Easy.perform(@url).body_str
    rescue
      raise 'Unable to load data from Github'
    end

    def method_missing(sym, *args, &block)
      load_data if @last_updated.nil?
      return unless @data.respond_to? sym
      instance_eval "def #{sym}(*args, &block) @data.#{sym}(*args, &block) end"
      send(sym, *args, &block)
    end
  end
end

require 'githubstats/data'
