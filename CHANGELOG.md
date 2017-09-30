# 2.0.0 / 2017-09-29

* [BUGFIX] Fail cleanly if Github responds with a bad HTTP code

# 1.4.0 / 2017-06-09

* [ENHANCEMENT] Cache more data methods
* [ENHANCEMENT] Upgrade to latest Nokogiri minor release

# 1.3.0 / 2016-09-14

* [FEATURE] Re-adds support for streak lookups longer than 366 days from GitHub, now that they've brought back older commit info

# 1.2.0 / 2016-05-19

* [BUGFIX] Remove support for streak lookup longer than 366 days from GitHub, since they removed display of longer streaks. :(

# 1.1.0 / 2015-08-19

* [FEATURE] For GitHub streaks longer than 1 year, GithubStats::User#streak and #longest_streak poll GitHub for the accurate streak size. The resulting array is left-padded with -1 entries for days with no known score

# 1.0.1 / 2015-07-16

* [ENHANCEMENT] Replace instance_eval with define_singleton_method for dynamic method passing
* [FEATURE] Add support for GitHub Enterprise via GITHUB_URL environment variable

# 1.0.0 / 2015-02-09

* [ENHANCEMENT] Stabilized API

