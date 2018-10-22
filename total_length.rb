#!/usr/bin/env ruby
total_length = ARGF.each_line.lazy.map{|l|
  chr,s,f, *rest = l.chomp.split("\t")
  f.to_i - s.to_i
}.inject(0.0, &:+)

if total_length > 1e6
  puts "%.3f M" % (total_length / 1e6)
elsif total_length > 1e3
  puts "%.3f k" % (total_length / 1e3)
else
  puts total_length
end
