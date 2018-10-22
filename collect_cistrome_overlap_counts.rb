def print_tf_region_table(hsh, tfs, regions, output_fn)
  File.open(output_fn, 'w') do |fw|
    fw.puts ['TF', *regions].join("\t")
    tfs.each{|tf|
      infos = hsh[tf].values_at(*regions)
      fw.puts [tf, *infos].join("\t")
    }
  end
end

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

num_peaks = Hash.new{|h,tf| h[tf] = {} }
num_overlapped_peaks = Hash.new{|h,tf| h[tf] = {} }
regions.each{|region|
  tfs.each{|tf|
    counts = File.readlines("results/num_tf_overlaps/#{region}/#{region}.#{tf}.tsv").map{|l|
      # there are {cnt} peaks which overlap {factor} enhancers each.
      # factor typically is 0, 1, 2, 3 (4 or 5 are very rare)
      cnt, factor = l.chomp.split("\t").map(&:to_i)
      [factor, cnt]
    }.to_h
    num_peaks[tf][region] = counts.values.sum
    num_overlapped_peaks[tf][region] = counts.select{|factor, _| factor > 0 }.values.sum
  }
}

print_tf_region_table(num_peaks, tfs, regions, 'results/num_peaks.tsv')
print_tf_region_table(num_overlapped_peaks, tfs, regions, 'results/num_overlapped_peaks.tsv')
