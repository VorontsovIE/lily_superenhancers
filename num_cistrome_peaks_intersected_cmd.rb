require 'fileutils'

MIN_PEAKS = 100
num_peaks_by_tf = File.readlines('results/cistrome_num_peaks.tsv').map{|l|
  tf, num_peaks = l.chomp.split("\t")
  [tf, Integer(num_peaks)]
}.to_h

# region can be e.g. enhancers/superenhancers/promoters
Dir.glob('results/genomic_intervals/*/*.bed').each do |region_fn|
  region = File.basename(region_fn, '.bed')
  FileUtils.mkdir_p "results/num_tf_overlaps/#{region}/"

  num_peaks_by_tf.select{|tf, num_peaks|
    num_peaks >= MIN_PEAKS
  }.sort.each do |tf, _|
    cmd = [
      "bedtools intersect -sorted -c -a results/cistrome_hg19_abc/#{tf}.bed -b #{region_fn}",
      'cut -f 4',
      'sort',
      'uniq -c',
      'sed -re "s/^\s*([0-9]+)\s+/\1\t/"'
    ].join(' | ')
    output_fn = "results/num_tf_overlaps/#{region}/#{region}.#{tf}.tsv"
    puts("#{cmd} > #{output_fn}")
  end
end
