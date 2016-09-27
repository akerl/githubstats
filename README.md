GithubStats
=========

[![Gem Version](https://img.shields.io/gem/v/githubstats.svg)](https://rubygems.org/gems/githubstats)
[![Dependency Status](https://img.shields.io/gemnasium/akerl/githubstats.svg)](https://gemnasium.com/akerl/githubstats)
[![Build Status](https://img.shields.io/circleci/project/akerl/githubstats/master.svg)](https://circleci.com/gh/akerl/githubstats)
[![Coverage Status](https://img.shields.io/codecov/c/github/akerl/githubstats.svg)](https://codecov.io/github/akerl/githubstats)
[![Code Quality](https://img.shields.io/codacy/d25d2521df3f4a6b8369edd419438d97.svg)](https://www.codacy.com/app/akerl/githubstats)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Grabs Github contribution statistics and presents it in an easily consumable format.

## Usage

Details of the methods provided for accessing data can be found [on RubyDoc.info](http://www.rubydoc.info/github/akerl/githubstats/)

A script is provided that uses the module to provide an overview of your contributions:

```
# githubstats
Contribution data for akerl:
    Today's score: 9
    Current streak: 32
    Longest streak: 32
    High score: 50 on 2013-07-14
    Quartile boundaries: [0, 3, 8, 12, 50]
▁▁▁▆▁▂▁▁▅▄▁▃▂▁▁▃▁▁▁▁▄▁▂▃█▇▃▁▃▃▂▁▃▂▁▁▁▁▁▁▂▁▁▁▁▂▂▁▃▁▂▁▆▃▂▂▁▁▁▅
```

The graph is generated using spark (https://github.com/holman/spark) if you have it installed.

Initializing a new Contributions object can be done as so:

```
require 'githubstats'
stats = GithubStats.new('akerl')
puts stats.data.today # Prints today's current score
```

### Username detection

The username is taken from the argument passed to .new(). If no username is provided, it will try to use Rugged (https://github.com/libgit2/rugged) to load the Github username from your git configuration. If Rugged isn't installed or no Github username is set, it falls back to the current session's user, pulled via ENV.

```
# whoami
akerl

# githubstats
Contribution data for akerl:
    Today's score: 9
    Current streak: 32
    Longest streak: 32
    High score: 50 on 2013-07-14
    Quartile boundaries: [0, 3, 8, 12, 50]
▁▁▁▆▁▂▁▁▅▄▁▃▂▁▁▃▁▁▁▁▄▁▂▃█▇▃▁▃▃▂▁▃▂▁▁▁▁▁▁▂▁▁▁▁▂▂▁▃▁▂▁▆▃▂▂▁▁▁▅

# githubstats mikegrb
Contribution data for mikegrb:
    Today's score: 0
    Current streak: 0
    Longest streak: 80
    High score: 23 on 2013-09-08
    Quartile boundaries: [0, 2, 5, 8, 23]
▁▁▂▂▂▁▁▁▁▃▁▁▄▁▁▁▄▂▁▂▄▁▁▂▄▃▂▁▁▁▁▁▄▃▁▁▁▁█▄▃▂▄▁▁▁▁▃▁▂▁▁▁▁▁▅▂▁▁▁

# head -2 .gitconfig
[github]
    user = fly

# gem install rugged
Building native extensions.  This could take a while...
Successfully installed rugged-0.21.4
1 gem installed

# githubstats
Contribution data for fly:
    Today's score: 0
    Current streak: 0
    Longest streak: 37
    High score: 28 on 2013-04-16
    Quartile boundaries: [0, 3, 8, 12, 28]
▁▁▁▁▂▁▁▁▁▁▁▁▁▁▁▁▄▁▁▃▂▁▆▄▁▁▂▄▃▃▁▁▁▁▁▁▆▂▆▄▄▄▁▁▂█▁▄▆▂▁▄▄▄█▄▁▄▂▁

```

### GitHub Enterprise

If you're using GitHub Enterprise, you can override the URL used by setting the GITHUB_URL environment variable or by passing the :url parameter when creating a GithubStats object.

## Installation

    gem install githubstats

## Contributors

* [Lee Matos](https://github.com/leematos) for help deconstructing Github's fancy Javascript math
* [Jon Chen](https://github.com/fly) for providing encouragement while borrowing my code

## License
GithubStats is released under the MIT License. See the bundled LICENSE file for details.

