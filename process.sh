# Merge cistrome ABC-categories for each factor and drop too long (and too short 50-10000 nt are allowed) peaks
ruby cistrome_merger_cmd.rb | bash
# Store number of peaks in each cistrome
ruby cistrome_num_peaks.rb > results/cistrome_num_peaks.tsv
