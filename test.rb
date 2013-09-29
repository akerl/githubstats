#!/usr/bin/env ruby

$:.unshift('.')
require 'lib/contributions'

contrib = Contributions.new ARGV.first

puts "Contribution data for #{contrib.user}:
    Today's score: #{contrib.today}
    Current streak: #{contrib.streak.length}
    Longest streak: #{contrib.longest_streak.length}
    High score: #{contrib.max.score} on #{contrib.max.date}
    Quartile boundaries: #{contrib.quartile_boundaries}"

