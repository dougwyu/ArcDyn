#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to rename the multiqc outputs
#######################################################################################
#######################################################################################

cd ~/_ArcDyn/PlatesA2B2/
RUN="A2B2"
echo ${RUN}
ls
mv multiqc_report.html multiqc_report_${RUN}.html
mv multiqc_data multiqc_data_${RUN}
ls

cd ~/_ArcDyn/PlatesAB/
RUN="AB"
echo ${RUN}
ls
mv multiqc_report.html multiqc_report_${RUN}.html
mv multiqc_data multiqc_data_${RUN}
ls

cd ~/_ArcDyn/PlatesEF/
RUN="EF"
echo ${RUN}
ls
mv multiqc_report.html multiqc_report_${RUN}.html
mv multiqc_data multiqc_data_${RUN}
ls

cd ~/_ArcDyn/PlatesGH/
RUN="GH"
echo ${RUN}
ls
mv multiqc_report.html multiqc_report_${RUN}.html
mv multiqc_data multiqc_data_${RUN}
ls



# 20190203:  realised that i ran fastqc on the pre-trimmed files, which are fastq.gz.
# so i removed the old fastqc files and re-ran fastqc and multiqc
# cd ~/_ArcDyn/PlatesEF/PlatesEF_combined/
# ls BWA*/Plate*/Plate*_R1_fastqc.zip | wc -l
# ls BWA*/Plate*/Plate*_R1_fastqc.html | wc -l
# ls BWA*/Plate*/Plate*_R2_fastqc.zip | wc -l
# ls BWA*/Plate*/Plate*_R2_fastqc.html | wc -l
#
# ls BWA*/Plate*/Plate*_R1_fastqc.zip
# ls BWA*/Plate*/Plate*_R1_fastqc.html
# ls BWA*/Plate*/Plate*_R2_fastqc.zip
# ls BWA*/Plate*/Plate*_R2_fastqc.html
#
# ls BWA*/Plate*/Plate*_R2_val_2_fastqc.html | wc -l  # should show nothing

# rm -f BWA*/Plate*/Plate*_R1_fastqc.zip
# rm -f BWA*/Plate*/Plate*_R1_fastqc.html
# rm -f BWA*/Plate*/Plate*_R2_fastqc.zip
# rm -f BWA*/Plate*/Plate*_R2_fastqc.html
