#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to copy idx and genomcov files into a directory to be downloaded to my computer
# run after running the samtools script, does not have to be uploaded to hpc
#######################################################################################
#######################################################################################

ssh hpc
interactive
# to use parallel without a pathname in bsub scripts
PATH=$PATH:~/scripts/parallel-20170722/bin/

OUTPUTFOLDER="minimap2_outputs"

####### cd into different folders and set up output folders to hold everything before running
####### the generic copy script below
# A2B2
PLATE="A2B2"
WORKINGPATH="$HOME/_ArcDyn/Plates${PLATE}/Plates${PLATE}_combined/"
cd ${WORKINGPATH}
ls
mkdir ${OUTPUTFOLDER}_Plates${PLATE}/
ls
ls ${OUTPUTFOLDER}_Plates${PLATE}/
"ls" -l BWA*/s*${PLATE}*.out # check if all BWA folders have a current smtl*.out file, showing that samtools ran correctly.  Check the sizes of the samtools.out file.  they should all be about the same.
####### THEN JUMP DOWN AND RUN THE GENERIC CODE below



# AB # different scripts because the pathnames are different
PLATE="AB"
WORKINGPATH="$HOME/_ArcDyn/Plates${PLATE}/Plates${PLATE}_combined/"
cd ${WORKINGPATH}
ls
mkdir ${OUTPUTFOLDER}_Plates${PLATE}/
ls
ls ${OUTPUTFOLDER}_Plates${PLATE}/
"ls" -l BWA*/s*${PLATE}*.out # check if all BWA folders have a current smtl*.out file, showing that samtools ran correctly.  Check the sizes of the samtools.out file.  they should all be about the same.
####### THEN JUMP DOWN AND RUN THE GENERIC CODE below



# EF
PLATE="EF"
WORKINGPATH="$HOME/_ArcDyn/Plates${PLATE}/Plates${PLATE}_combined/"
cd ${WORKINGPATH}
ls
mkdir ${OUTPUTFOLDER}_Plates${PLATE}/
ls
ls ${OUTPUTFOLDER}_Plates${PLATE}/
"ls" -l BWA*/s*${PLATE}*.out # check if all BWA folders have a current smtl*.out file, showing that samtools ran correctly.  Check the sizes of the samtools.out file.  they should all be about the same.
####### THEN JUMP DOWN AND RUN THE GENERIC CODE below



# GH
PLATE="GH"
WORKINGPATH="$HOME/_ArcDyn/Plates${PLATE}/Plates${PLATE}_combined/"
cd ${WORKINGPATH}
ls
mkdir ${OUTPUTFOLDER}_Plates${PLATE}/
ls
ls ${OUTPUTFOLDER}_Plates${PLATE}/
"ls" -l BWA*/s*${PLATE}*.out # check if all BWA folders have a current smtl*.out file, showing that samtools ran correctly.  Check the sizes of the samtools.out file.  they should all be about the same.
####### THEN JUMP DOWN AND RUN THE GENERIC CODE below


####### GENERIC CODE to copy samtools output files to:  outputs_Plates${PLATE}_${FILTER1}_q${QUAL2}_${OUTPUTFOLDER}_${MAPDATE}_${TARGET}.tar.gz #######
####### This folder is then downloaded to my laptop to process with R:  idxstats_tabulate_macOS_Plates*.Rmd
####### Run once for each library:  A2B2, AB, EF, GH

# set filters and minimum mapping quality scores
FILTER1="F2308_f0x2" # filter 1
FILTER2="F2308" # filter 2
echo $FILTER1
echo $FILTER2
QUAL1=""; echo $QUAL1 # set to "" if i don't want to use this variable for, say, q1
QUAL2=48; echo $QUAL2

echo $PLATE # check that i'm going to the right folder
echo $OUTPUTFOLDER

# copy output files into minimap2_outputs_Plates${PLATE}/
# e.g. Sample_IPO3916_C5_F2308_f0x2_q60_sorted.bam_idxstats.txt
# check before copying
parallel ls -l BWA*/${OUTPUTFOLDER}/*_{1}_q{2}_sorted.bam_idxstats.txt ::: ${FILTER1} ${FILTER2} ::: ${QUAL1} ${QUAL2}
parallel ls BWA*/${OUTPUTFOLDER}/*_{1}_q{2}_sorted.bam_idxstats.txt ::: ${FILTER1} ${FILTER2} ::: ${QUAL1} ${QUAL2} | wc -l # A2B2: 342 files == 171*2; AB: 384 == 192*2; EF: 384 files; GH: 380;
# copy
parallel cp BWA*/${OUTPUTFOLDER}/*_{1}_q{2}_sorted.bam_idxstats.txt ${OUTPUTFOLDER}_Plates${PLATE}/ ::: ${FILTER1} ${FILTER2} ::: ${QUAL1} ${QUAL2}
# check after copying
ls ${OUTPUTFOLDER}_Plates${PLATE}/
ls ${OUTPUTFOLDER}_Plates${PLATE}/*_q*_sorted.bam_idxstats.txt | wc -l # A2B2: 342; AB:384; EF: 382; GH: 380
# copy flagstat files
cp BWA*/${OUTPUTFOLDER}/*_sorted.bam.flagstat.txt ${OUTPUTFOLDER}_Plates${PLATE}/
ls ${OUTPUTFOLDER}_Plates${PLATE}/
ls ${OUTPUTFOLDER}_Plates${PLATE}/*_sorted.bam.flagstat.txt | wc -l # half the idxstats values

# e.g. Sample_IPO3916_C5_F2308_f0x2_q1_sorted_genomecov_d.txt.gz
# check
parallel ls -l BWA*/${OUTPUTFOLDER}/*_{1}_q{2}_sorted_genomecov_d.txt.gz ::: ${FILTER1} ${FILTER2} ::: ${QUAL1} ${QUAL2}
parallel ls -l BWA*/${OUTPUTFOLDER}/*_{1}_q{2}_sorted_genomecov_d.txt.gz ::: ${FILTER1} ${FILTER2} ::: ${QUAL1} ${QUAL2} | wc -l # A2B2: 342; AB: 384; EF: 384; GH: 380;
# copy
parallel cp BWA*/${OUTPUTFOLDER}/*_{1}_q{2}_sorted_genomecov_d.txt.gz ${OUTPUTFOLDER}_Plates${PLATE}/ ::: ${FILTER1} ${FILTER2} ::: ${QUAL1} ${QUAL2}  # takes considerably longer than above
# check again
parallel ls ${OUTPUTFOLDER}_Plates${PLATE}/*_{1}_q{2}_sorted_genomecov_d.txt.gz ::: ${FILTER1} ${FILTER2} ::: ${QUAL1} ${QUAL2} | wc -l # A2B2: 342; AB: 384; EF: 384; GH: 380;

# rename, tar, and gzip for download
MAPDATE="20190202"
TARGET="349MITOCOICYTB" # "308mitogenomes", "406barcodes", "349MTCOICYTB"
du -sh ${OUTPUTFOLDER}_Plates${PLATE}/ # ~4.5-5.0 GB
# set filename to something that i can understand after download
mv ${OUTPUTFOLDER}_Plates${PLATE} outputs_Plates${PLATE}_${FILTER1}_q${QUAL2}_${OUTPUTFOLDER}_${MAPDATE}_${TARGET}
ls # e.g. outputs_PlatesA2B2_F2308_f0x2_q48_minimap2_outputs_20190115_308mitogenomes/
# tar gzip for download
tar -czvf outputs_Plates${PLATE}_${FILTER1}_q${QUAL2}_${OUTPUTFOLDER}_${MAPDATE}_${TARGET}.tar.gz outputs_Plates${PLATE}_${FILTER1}_q${QUAL2}_${OUTPUTFOLDER}_${MAPDATE}_${TARGET}/
# filename format:  outputs_PlatesA2B2_F2308_f0x2_q48_minimap2_outputs_20190115_308mitogenomes.tar.gz
ls
rm -rf outputs_Plates${PLATE}_${FILTER1}_q${QUAL2}_${OUTPUTFOLDER}_${MAPDATE}_${TARGET}/
ls

######## remove the minimap2_output/ folders after i've finished the mapping jobs. these are the bam, bam.bai, idxstats, flagstats, and genomecov files left behind in the BWA folders
PATH=$PATH:~/scripts/parallel-20170722/bin/
# FILTER="F2308"
OUTPUTFOLDER="minimap2_outputs"

# A2B2
PLATE="A2B2"
WORKINGPATH="$HOME/_ArcDyn/Plates${PLATE}/Plates${PLATE}_combined/"
cd ${WORKINGPATH}
ls
parallel "ls BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
# parallel "rm -rf BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
parallel "ls BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
# ls: cannot access BWA*/minimap2_outputs/: No such file or directory

# AB # different scripts because the pathnames are different
PLATE="AB"
WORKINGPATH="$HOME/_ArcDyn/Plates${PLATE}/Plates${PLATE}_combined/"
cd ${WORKINGPATH}
ls
parallel "ls BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
# parallel "rm -rf BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
parallel "ls BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
# ls: cannot access BWA*/minimap2_outputs/: No such file or directory

# EF
PLATE="EF"
WORKINGPATH="$HOME/_ArcDyn/Plates${PLATE}/Plates${PLATE}_combined/"
cd ${WORKINGPATH}
ls
parallel "ls BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
# parallel "rm -rf BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
parallel "ls BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
# ls: cannot access BWA*/minimap2_outputs/: No such file or directory


# GH
PLATE="GH"
WORKINGPATH="$HOME/_ArcDyn/Plates${PLATE}/Plates${PLATE}_combined/"
cd ${WORKINGPATH}
ls
parallel "ls BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
# parallel "rm -rf BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
parallel "ls BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
# ls: cannot access BWA*/minimap2_outputs/: No such file or directory


# when i'm on a fast network, i can download using scp, but otherwise, use Transmit for robustness
### 2016 run:  AB ###
# on macOS
# download outputs_Plates${PLATE}_${FILTER1}_q${QUAL2}_${OUTPUTFOLDER}_${MAPDATE}_${TARGET}.tar.gz
# scp b042@hpc.uea.ac.uk:~/_ArcDyn/PlatesAB/PlatesAB_combined/outputs_Plates${PLATE}_${FILTER1}_q${QUAL2}_${OUTPUTFOLDER}_${MAPDATE}_${TARGET}.tar.gz  ~/Dropbox/Working_docs/Roslin_Greenland/2016/bulk_samples/PlatesAB_EI_20160512/
#
# cd /Users/Negorashi2011/Dropbox/Working_docs/Roslin_Greenland/2016/bulk_samples/PlatesAB_EI_20160512/
#
# scp b042@hpc.uea.ac.uk:~/_ArcDyn/platesEF/PlatesEF_combined/fastqc_completed/bwa_all_outputs_PlatesEF_F2308_COIBarcode.tar.gz  ~/Dropbox/Working_docs/Roslin_Greenland/2017/bulk_samples/PlatesEF/
#
# cd ~/Dropbox/Working_docs/Roslin_Greenland/2017/bulk_samples/PlatesEF/
