require File.join(Dir.pwd, 'lib/github_stats.rb')

Gem::Specification.new do |s|
  s.name        = 'github_stats'
  s.version     = Github_Stats::Version
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = 'Present Github contributions stats in a consumable format'
  s.description = "Pulls the statistics from Github's user contribution chart and provides an interface for analyzing that data"
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.files       = `git ls-files`.split
  s.executables = ['github_stats']
  s.homepage    = 'https://github.com/akerl/github_stats'
  s.license     = 'MIT'
end

