# Merge cistrome ABC-categories for each factor and drop too long (and too short 50-10000 nt are allowed) peaks
ruby cistrome_merger_cmd.rb | bash
# Store number of peaks in each cistrome
ruby cistrome_num_peaks.rb > results/cistrome_num_peaks.tsv

# Normalize (sort) enhancers in each file
find source_data/enhancers_bed/ -xtype f | xargs -n1 -I{} echo 'bedtools sort -i {} | sponge {}' | bash

# Split enhancers into separate files: superenhancers/enhancers/promoters
for i in `seq 1 6`; do
  awk -e '($4=="SE"){print $0}' -- source_data/enhancers_bed/${i}_h3k27ac.scores.bed > results/genomic_intervals/superenhancers/superenhancers_${i}.bed
  awk -e '($4=="promoter"){print $0}' -- source_data/enhancers_bed/${i}_h3k27ac.scores.bed > results/genomic_intervals/promoters/promoters_${i}.bed
  awk -e '($4=="enhancer"){print $0}' -- source_data/enhancers_bed/${i}_h3k27ac.scores.bed > results/genomic_intervals/enhancers/enhancers_${i}.bed
done

# For each cistrome peak calculate number of intersections with enhancers.
# We store number of peaks which were intersected once, twice (usually ~10% of the former for typical enhancers,
#   and 0% for superenhancers) etc or not intersected at all.
ruby num_cistrome_peaks_intersected.rb
