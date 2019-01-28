# ArcDyn

This version is the first draft version of the code for publication. This version of the code resulted from re-running the entire ArcDyn pipeline from the beginning (i.e. from the original sequence files received from sequencing centre). The scripts here represent Step 4 in Box 1 of the ArcDyn methods paper.

- downloading and concatenating the fastq files for each sample

- TrimGalore to remove adapters and filter out bad reads

- fastQC and multiQC to generate summary statistics

- minimap2 and samtools to map reads to mitogenomes and barcodes and to filter the bam files, also run bedtools to calculate coverage per position

- merge and process the idxstats and genomecov files, merge by Run, and generate input data files for statistical analysis. 

- The statistical analysis code is not here (in the Supp Info folder of the manuscript for now)

- reference files for use above (reference mitogenomes and barcodes, sample metadata, and taxonomy information for the mitogenomes and barcodes)

Created on 20180126
