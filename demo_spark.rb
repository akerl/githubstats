#!/usr/bin/env ruby

$:.unshift('.')
require 'lib/contributions'

contrib = Contributions.new ARGV.first
recent_scores = contrib.data.pop(50).collect { |point| point.score.to_s }
system('spark', *recent_scores)

