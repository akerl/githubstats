#!/usr/bin/env ruby

require_relative 'lib/contributions'


begin
    contrib = Contributions.new "#{ARGV.first}"
rescue ArgumentError
    contrib = Contributions.new 'akerl'
end

puts "Contribution data for #{contrib.user}:
    Today's score: #{contrib.today}
    Current streak: #{contrib.streak.length}
    High score: #{contrib.max.score} on #{contrib.max.date}"

