#!/usr/bin/env ruby
output_all = ARGV.delete('--all')
ARGF.each_line{|l|
  chr,s,f, *rest = l.chomp.split("\t")
  len = f.to_i - s.to_i
  if output_all
    puts [chr, s, f, *rest, len].join("\t")
  else
    puts len
  end
}
