#!/usr/bin/env ruby

ROOT = File.expand_path('../..', __FILE__)
$: << File.join(ROOT, 'lib')
require 'pattern_matching'

def run_file(filepath)
  if ENV['DEBUG']
    puts

    puts "[DEBUG] Running #{filepath}:"

    puts PatternMatching
      .process(File.read(filepath))
      .split("\n")
      .map
      .with_index { |line, index| "#{(index + 1).to_s.rjust(6)}: #{line}" }

    puts
  end

  PatternMatching.require(filepath)
end

ARGV.each do |filepath|
  run_file(filepath)
end
