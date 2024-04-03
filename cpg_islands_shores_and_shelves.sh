# get the CpG islands
wget -qO- http://hgdownload.cse.ucsc.edu/goldenpath/hg38/database/cpgIslandExt.txt.gz \
   | gunzip -c \
   | awk 'BEGIN{ OFS="\t"; }{ print $2, $3, $4, $5$6, $7, $8, $9, $10, $11, $12 }' \
   > cpgIslandExt.hg38.bed
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chrom.sizes
# generate bed file for chr1-22,X,Y,M
python3 chr1-22XYM.py

# CpG islands bed file cleaning
bedtools intersect -a cpgIslandExt.hg38.bed -b hg38_chr1-22XYM.bed -wa > cpgIslandExt.hg38.chr1-22XYM.bed
bedtools sort -i ./cpgIslandExt.hg38.chr1-22XYM.bed -g hg38.chrom.sizes > cpgIslandExt.hg38.sorted.bed

# shore is 2kb flanking region of CpG islands upstream and downstream that does not overlap with CpG islands
bedtools flank -i cpgIslandExt.hg38.sorted.bed -g hg38.chrom.sizes -b 2000 > cpgShores.hg38.bed
bedtools subtract -a cpgShores.hg38.bed -b cpgIslandExt.hg38.sorted.bed  > cpgShores.hg38.not_an_island.bed
bedtools subtract -A -a cpgShores.hg38.bed -b cpgIslandExt.hg38.sorted.bed  > cpgShores.hg38.not_overlapping_an_island.bed
# awk '$3-$2 == 2000' cpgShores.hg38.not_an_island.bed > cpgShores.hg38.not_an_island.size2k.bed
# diff cpgShores.hg38.not_an_island.size2k.bed cpgShores.hg38.not_overlapping_an_island.bed

# shelf is 2kb flanking region of CpG islands upstream and downstream from shores that does not overlap with CpG islands or shores
bedtools flank -i cpgIslandExt.hg38.sorted.bed -g hg38.chrom.sizes -b 4000 > cpgShelvesandShores.hg38.bed
bedtools subtract -a cpgShelvesandShores.hg38.bed -b cpgShores.hg38.bed  > cpgShelves.hg38.bed
bedtools subtract -a cpgShelves.hg38.bed -b cpgIslandExt.hg38.sorted.bed  > cpgShelves.hg38.not_an_island.bed
awk '$3-$2 == 2000' cpgShelves.hg38.not_an_island.bed > cpgShelves.hg38.not_an_island.size2k.bed

# create concatenated files for CpG features
cat cpgIslandExt.hg38.sorted.bed cpgShores.hg38.not_an_island.bed cpgShelves.hg38.not_an_island.bed > cpgIslandShoreShelf.hg38.bed
bedtools sort -i cpgIslandShoreShelf.hg38.bed > cpgIslandShoreShelf.hg38.sorted.bed

# create concatenated files for CpG features
cat cpgIslandExt.hg38.sorted.bed cpgShores.hg38.not_overlapping_an_island.bed cpgShelves.hg38.not_an_island.size2k.bed > cpgIslandShoreShelf.full2kShoresandShelves.hg38.bed
bedtools sort -i cpgIslandShoreShelf.full2kShoresandShelves.hg38.bed > cpgIslandShoreShelf.full2kShoresandShelves.hg38.sorted.bed

mkdir bed_files
cp cpgIslandExt.hg38.sorted.bed bed_files/cpgIslands.hg38.bed
cp cpgShores.hg38.not_overlapping_an_island.bed bed_files/cpgShores.hg38.full2k.bed
cp cpgShores.hg38.not_an_island.bed bed_files/cpgShores.hg38.bed
cp cpgShelves.hg38.not_an_island.bed bed_files/cpgShelves.hg38.bed
cp cpgShelves.hg38.not_an_island.size2k.bed bed_files/cpgShelves.hg38.full2k.bed
cp cpgIslandShoreShelf.hg38.sorted.bed bed_files/cpgIslandShoreShelf.hg38.bed
cp cpgIslandShoreShelf.full2kShoresandShelves.hg38.sorted.bed bed_files/cpgIslandShoreShelf.full2kShoresandShelves.hg38.bed


