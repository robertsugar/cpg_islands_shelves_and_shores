import pandas as pd

df =pd.read_csv("hg38.chrom.sizes", sep='\t', header=None)

# pick rows where 0 is in chr1, chr2, ... chr22, chrX, chrY or chrM
df = df[df[0].isin([f'chr{i}' for i in range(1, 23)] + ['chrX', 'chrY', 'chrM'])]

# insert new column between 0 and 1 with all 0-s
df.insert(1, '0', 0)

# write to file "hg38_chr1-22XYM.bed" with \t separator, no header or index, first 3 columns
df.to_csv("hg38_chr1-22XYM.bed", sep='\t', header=False, index=False, columns=[0, '0', 1])

