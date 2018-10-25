# {key: value}
def print_hash_as_table(hsh, header: nil, output_fn:)
  File.open(output_fn, 'w') do |fw|
    fw.puts header.join("\t")  if header
    hsh.each{|k,v|
      fw.puts [k, v].join("\t")
    }
  end
end

# {row_1: {col_1: value, col_2: value, ...}, ...}
def print_2d_hash_as_table(hsh, row_names:, col_names:, row_variable_name: nil, output_fn:)
  File.open(output_fn, 'w') do |fw|
    fw.puts [row_variable_name, *col_names].join("\t")
    row_names.each{|row_name|
      infos = hsh[row_name].values_at(*col_names)
      fw.puts [row_name, *infos].join("\t")
    }
  end
end

# enhancer_counts = Dir.glob('results/genomic_intervals/*/*.bed').map{|fn|
#   [File.basename(fn,'.bed'), File.readlines(fn).size]
# }.to_h

enhancer_total_lengths = Dir.glob('results/genomic_intervals/*/*.bed').map{|fn|
  length = File.readlines(fn).map{|l|
    chr,s,f = l.chomp.split("\t")
    Integer(f) - Integer(s)
  }.inject(0, &:+)
  [File.basename(fn,'.bed'), length]
}.to_h

regions = Dir.glob('results/num_tf_overlaps/*').select{|fn|
  File.directory?(fn)
}.map{|fn|
  File.basename(fn)
}.sort

tfs = regions.flat_map{|region|
  Dir.glob("results/num_tf_overlaps/#{region}/*.tsv")
}.map{|fn|
  File.basename(fn, '.tsv').split('.').last
}.uniq.sort

num_peaks = {}
num_overlapped_peaks = Hash.new{|h,tf| h[tf] = {} }
regions.each{|region|
  tfs.each{|tf|
    counts = File.readlines("results/num_tf_overlaps/#{region}/#{region}.#{tf}.tsv").map{|l|
      # there are {cnt} peaks which overlap {factor} enhancers each.
      # factor typically is 0, 1, 2, 3 (4 or 5 are very rare)
      cnt, factor = l.chomp.split("\t").map(&:to_i)
      [factor, cnt]
    }.to_h
    num_peaks[tf] ||= counts.values.sum # it doesn't depend on region so can be calculated once
    num_overlapped_peaks[tf][region] = counts.select{|factor, _| factor > 0 }.values.sum
  }
}

length_overlapped_peaks = Hash.new{|h,tf| h[tf] = {} }
regions.each{|region|
  tfs.each{|tf|
    length = File.read("results/length_tf_overlaps/#{region}/#{region}.#{tf}.tsv")
    length_overlapped_peaks[tf][region] = Integer(length)
  }
}

print_hash_as_table(enhancer_counts, output_fn: 'results/num_enhancers.tsv')
print_hash_as_table(enhancer_total_lengths, output_fn: 'results/length_enhancers.tsv')
print_hash_as_table(num_peaks, output_fn: 'results/num_peaks.tsv')
print_2d_hash_as_table(num_overlapped_peaks, row_names: tfs, col_names: regions, row_variable_name: 'TF', output_fn: 'results/num_overlapped_peaks.tsv')
print_2d_hash_as_table(length_overlapped_peaks, row_names: tfs, col_names: regions, row_variable_name: 'TF', output_fn: 'results/length_overlapped_peaks.tsv')
