#!/usr/bin/env ruby

$:.unshift('.')
require 'lib/contributions'

names = [ARGV.first]
begin
    require 'rugged'
    names << Rugged::Config.global['github.user']
rescue LoadError
end
names << ENV['USER']

names.reject! {|name| name.nil? }
abort "No user provided" if names.empty?

contrib = Contributions.new names.first

puts "Contribution data for #{contrib.user}:
    Today's score: #{contrib.today}
    Current streak: #{contrib.streak.length}
    Longest streak: #{contrib.longest_streak.length}
    High score: #{contrib.max.score} on #{contrib.max.date}"

