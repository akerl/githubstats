#!/usr/bin/env ruby

require_relative 'lib/contributions'
require 'rugged'

gitconfig = Rugged::Config

contrib = Contributions.new(ARGV.first || gitconfig.global['github.user'] || 'akerl')

puts "Contribution data for #{contrib.user}:
    Today's score: #{contrib.today}
    Current streak: #{contrib.streak.length}
    High score: #{contrib.max.score} on #{contrib.max.date}"

