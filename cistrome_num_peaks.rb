Dir.glob("results/cistrome_hg19_abc/*.bed").sort.each do |fn|
  tf = File.basename(fn, ".bed")
  num_peaks = File.open(fn){|f| f.each_line.count }
  infos = [tf, num_peaks]
  puts infos.join("\t")
end
