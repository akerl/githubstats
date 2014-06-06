Gem::Specification.new do |s|
  s.name        = 'githubstats'
  s.version     = '0.2.11'
  s.date        = Time.now.strftime("%Y-%m-%d")

  s.summary     = 'Present Github contributions stats in a consumable format'
  s.description = "Pulls the statistics from Github's user contribution chart and provides an interface for analyzing that data"
  s.authors     = ['Les Aker']
  s.email       = 'me@lesaker.org'
  s.homepage    = 'https://github.com/akerl/githubstats'
  s.license     = 'MIT'

  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files spec/*`.split
  s.executables = ['githubstats']

  s.add_runtime_dependency 'curb', '~> 0.8.5'
  s.add_runtime_dependency 'basiccache', '~> 0.1.0'

  s.add_development_dependency 'timecop', '~> 0.7.1'
  s.add_development_dependency 'rubocop', '~> 0.23.0'
  s.add_development_dependency 'rake', '~> 10.3.2'
  s.add_development_dependency 'coveralls', '~> 0.7.0'
  s.add_development_dependency 'rspec', '~> 3.0.0'
  s.add_development_dependency 'fuubar', '~> 2.0.0.rc1'
end
