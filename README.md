GithubStats
=========

[![Gem Version](https://badge.fury.io/rb/githubstats.png)](http://badge.fury.io/rb/githubstats)
[![Dependency Status](https://gemnasium.com/akerl/githubstats.png)](https://gemnasium.com/akerl/githubstats)
[![Code Climate](https://codeclimate.com/github/akerl/githubstats.png)](https://codeclimate.com/github/akerl/githubstats)
[![Coverage Status](https://coveralls.io/repos/akerl/githubstats/badge.png?branch=master)](https://coveralls.io/r/akerl/githubstats?branch=master)
[![Build Status](https://travis-ci.org/akerl/githubstats.png?branch=master)](https://travis-ci.org/akerl/githubstats)

Grabs Github contribution statistics and presents it in an easily consumable format.

## Usage

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

The username is taken from the argument passed to .new(). If no username is provided, it will try to use Rugged (https://github.com/libgit2/rugged) to load the Github username from your git configuration. If Rugged isn't installed or no Github username is set, it falls back to the current session's user, pulled via ENV.

```
# whoami
akerl

# head -2 .gitconfig
[github]
    user = fly

# gem list | grep rugged
rugged (0.19.0)

# githubstats mikegrb
Contribution data for mikegrb:
    Today's score: 0
    Current streak: 0
    Longest streak: 80
    High score: 23 on 2013-09-08
    Quartile boundaries: [0, 2, 5, 8, 23]
▁▁▂▂▂▁▁▁▁▃▁▁▄▁▁▁▄▂▁▂▄▁▁▂▄▃▂▁▁▁▁▁▄▃▁▁▁▁█▄▃▂▄▁▁▁▁▃▁▂▁▁▁▁▁▅▂▁▁▁

# githubstats
Contribution data for fly:
    Today's score: 0
    Current streak: 0
    Longest streak: 37
    High score: 28 on 2013-04-16
    Quartile boundaries: [0, 3, 8, 12, 28]
▁▁▁▁▂▁▁▁▁▁▁▁▁▁▁▁▄▁▁▃▂▁▆▄▁▁▂▄▃▃▁▁▁▁▁▁▆▂▆▄▄▄▁▁▂█▁▄▆▂▁▄▄▄█▄▁▄▂▁

# gem uninstall rugged
Successfully uninstalled rugged-0.19.0

# githubstats
Contribution data for akerl:
    Today's score: 9
    Current streak: 32
    Longest streak: 32
    High score: 50 on 2013-07-14
    Quartile boundaries: [0, 3, 8, 12, 50]
▁▁▁▆▁▂▁▁▅▄▁▃▂▁▁▃▁▁▁▁▄▁▂▃█▇▃▁▃▃▂▁▃▂▁▁▁▁▁▁▂▁▁▁▁▂▂▁▃▁▂▁▆▃▂▂▁▁▁▅

#
```

## Installation

    gem install githubstats

## Contributors

* [Lee Matos](https://github.com/leematos) for help deconstructing Github's fancy Javascript math
* [Jon Chen](https://github.com/fly) for providing encouragement while borrowing my code

## License
GithubStats is released under the MIT License. See the bundled LICENSE file for details.

