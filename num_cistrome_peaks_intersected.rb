require 'fileutils'

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

##################################################################

regions = Dir.glob('results/genomic_intervals/*/*.bed').map{|fn|
  File.basename(fn, '.bed')
}.sort

num_peaks_by_tf = File.readlines('results/cistrome_num_peaks.tsv').map{|l|
  tf, cnt = l.chomp.split("\t")
  [tf, Integer(cnt)]
}.to_h

tfs = num_peaks_by_tf.keys.sort

##################################################################

num_peaks = {}
num_overlapped_peaks = Hash.new{|h,tf| h[tf] = {} }
# region can be e.g. enhancers/superenhancers/promoters
Dir.glob('results/genomic_intervals/*/*.bed').each do |region_fn|
  region = File.basename(region_fn, '.bed')
  FileUtils.mkdir_p "results/num_tf_overlaps/#{region}/"

  num_peaks_by_tf.keys.sort.each do |tf|
    cmd = [
      "bedtools intersect -sorted -c -a results/cistrome_hg19_abc/#{tf}.bed -b #{region_fn}",
      'cut -f 4',
      'sort',
      'uniq -c',
    ].join(' | ')
    counts = `#{cmd}`.lines.map{|l|
      cnt, multiplicity = l.strip.split.map(&:to_i)
      [multiplicity, cnt]
    }.to_h
    num_peaks[tf] ||= counts.values.sum # it doesn't depend on region so can be calculated once
    num_overlapped_peaks[tf][region] = counts.select{|factor, _| factor > 0 }.values.sum
  end
end

print_hash_as_table(num_peaks, output_fn: 'results/num_peaks.tsv')
print_2d_hash_as_table(num_overlapped_peaks, row_names: tfs, col_names: regions, row_variable_name: 'TF', output_fn: 'results/num_overlapped_peaks.tsv')

##################################################################

length_overlapped_peaks = Hash.new{|h,tf| h[tf] = {} }
tfs.each do |tf|
  regions.each do |region|
    region_type = region.split('_').first
    cmd = [
      "bedtools intersect -sorted -wa -a results/cistrome_hg19_abc/#{tf}.bed -b results/genomic_intervals/#{region_type}/#{region}.bed",
      'ruby total_length.rb --numeric',
    ].join(' | ')
    length_overlapped_peaks[tf][region] = Integer(`#{cmd}`)
  end
end

print_2d_hash_as_table(length_overlapped_peaks, row_names: tfs, col_names: regions, row_variable_name: 'TF', output_fn: 'results/length_overlapped_peaks.tsv')

##################################################################

enhancer_counts = Dir.glob('results/genomic_intervals/*/*.bed').map{|fn|
  [File.basename(fn,'.bed'), File.readlines(fn).size]
}.to_h

print_hash_as_table(enhancer_counts, output_fn: 'results/num_enhancers.tsv')

##################################################################

enhancer_total_lengths = Dir.glob('results/genomic_intervals/*/*.bed').map{|fn|
  length = File.readlines(fn).map{|l|
    chr,s,f = l.chomp.split("\t")
    Integer(f) - Integer(s)
  }.inject(0, &:+)
  [File.basename(fn,'.bed'), length]
}.to_h

print_hash_as_table(enhancer_total_lengths, output_fn: 'results/length_enhancers.tsv')
