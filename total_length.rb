#!/usr/bin/env ruby

numeric_format = ARGV.delete '--numeric'
total_length = ARGF.each_line.lazy.map{|l|
  chr,s,f, *rest = l.chomp.split("\t")
  f.to_i - s.to_i
}.inject(0, &:+)

if numeric_format
  puts total_length
else
  if total_length > 1e6
    puts "%.3f M" % (total_length.to_f / 1e6)
  elsif total_length > 1e3
    puts "%.3f k" % (total_length.to_f / 1e3)
  else
    puts total_length
  end
end