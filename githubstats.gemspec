require 'English'
$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'githubstats/version'

Gem::Specification.new do |s|
  s.name        = 'githubstats'
  s.version     = GithubStats::VERSION
  s.required_ruby_version = '>= 2.6.0'

  s.summary     = 'Present Github contributions stats in a consumable format'
  s.description = 'Pulls the statistics from Github\'s user contribution chart and provides an interface for analyzing that data' # rubocop:disable Layout/LineLength
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/akerl/githubstats'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.executables = ['githubstats']

  s.add_runtime_dependency 'basiccache', '~> 1.0.0'
  s.add_runtime_dependency 'nokogiri', '~> 1.15.3'

  s.add_development_dependency 'goodcop', '~> 0.9.7'
  s.add_development_dependency 'timecop', '~> 0.9.6'
  s.metadata['rubygems_mfa_required'] = 'true'
end
