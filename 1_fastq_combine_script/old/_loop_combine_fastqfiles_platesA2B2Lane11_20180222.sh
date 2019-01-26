#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to loop through a set of fastq files and combine them
# in this case, i combine final set of sequences from the Lane 11 run of PlatesA2B2
# with the previous two runs (Lanes 1-10)
# Because i already trimmed the Lanes 1-10 seqs, i also first trim the Lane 11 seqs and
# then cat the val_{1,2}.fq.gz files
# for safety, i have archived the platesA2B2_combined/ folder
#######################################################################################
#######################################################################################

# Usage:
# Interactive procedure:  run these commands before running _loop_combine_fastqfiles_20180202.sh interactively
# interactive
# cd into folder holding the fastq files (e.g. ~/greenland_2017/platesA2B2/)
# upload _loop_combine_fastqfiles_20180202.sh into the folder
# bash _loop_combine_fastqfiles_20180202.sh


# PLAN:
     # change platesA2B2_combined/ to PKG_platesA2B2_combined_Lanes1_10/
  # make list of sample names (the folders for each set of fastq files, corresponding to a single sample/well)
     # for example: Sample_PRO1322_PlateB_H9
  # create the Sample_combined folder to hold the new fastq files
  # combine fastq files to the new Sample_combined folder
  # remove the original sample files

# set variables
PIPESTART=$(date)
HOMEFOLDER=$(pwd)
echo "Home folder is ${HOMEFOLDER}"  # Home folder is /gpfs/home/b042/greenland_2017/platesA2B2
COMBINEDFASTQ=$(basename ${HOMEFOLDER})
echo "COMBINEDFASTQ folder will be ${COMBINEDFASTQ}_combined/"
INDEX=1

# mkdir to hold output
if [ ! -d "${COMBINEDFASTQ}_combined" ] # if directory ${COMBINEDFASTQ}_combined does not exist
then
	mkdir "${COMBINEDFASTQ}_combined"
fi

# these are the two runs for platesA2B2 (lanes 1-10 were run on 20180123, lane 11 was received on 20180222)
# platesA2B2/PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane
# platesA2B2/PKG_platesA2B2_combined_Lanes1_10

# to make it possible to cat files within both these folders, i make it easy on myself and rename platesA2B2_combined_Lanes1_10 to PKG_platesA2B2_combined_Lanes1_10


# read in folder list and make a bash array
# find all Sample_files in PKG_platesA2B2_combined_Lanes1_10 and add to well_list.txt
find PKG_platesA2B2_combined_Lanes1_10 -maxdepth 2 -type d -name "Sample_*" | sed -E 's/PKG_platesA2B2_combined_Lanes1_10\/BWA[0-9]+\///g' | sort | uniq - > well_list1.txt # the 'PKG_platesA2B2_combined_Lanes1_10\/BWA[0-9]+\/' looks for PKG_platesA2B2_combined_Lanes1_10/BWA01/ for all numbers after BWA
# wc -l well_list.txt # 168 unique names

# find all PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane and add to well_list2.txt
# note that i have put all samples files into a subfolder BWA01 to match the hierarchy in PKG_platesA2B2_combined_Lanes1_10/
find PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane -maxdepth 2 -type d -name "Sample_*" | sed -E 's/PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane\/BWA01\///g' | sort | uniq - > well_list2.txt # the '/PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane\/BWA01\///g' looks for PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane/BWA01/
# wc -l well_list2.txt # 168 unique names

# combine the three files and keep only uniques
cat well_list1.txt well_list2.txt | sort | uniq - > well_list.txt
# less well_list.txt
# wc -l well_list1.txt  # 168 unique names.  there are 3 more samples that were in Lane 11.  the other samples are only additional
# wc -l well_list2.txt  # 168 unique names.  there are 3 more samples that were in Lane 11.  the other samples are only additional
# wc -l well_list.txt  # 171 unique names.  there are 3 more samples that were in Lane 11.  the other samples are only additional
# rm -f well_list1.txt
# rm -f well_list2.txt

# omit samples that don't appear in both folders (because my cat command below crashes)
# these samples are probably in Lanes1-10, not in Lane 11 (check well_list1,2.txt, and cp the folders over into the new combined fastq folder)
# I will probably end up writing multiple grep lines here
grep -v "^Sample_PRO1322_PlateA_F11$" well_list.txt > well_list_tmp.txt # ^ means the start, $ means the end of the string
# grep "^Sample_PRO1322_PlateA_F11$" well_list.txt
# grep "^Sample_PRO1322_PlateA_F11$" well_list_tmp.txt
mv well_list_tmp.txt well_list.txt
# grep "^Sample_PRO1322_PlateA_F11$" well_list.txt

# grep "^Sample_PRO1322_PlateB_A1$" well_list.txt
grep -v "^Sample_PRO1322_PlateB_A1$" well_list.txt > well_list_tmp.txt
# grep "^Sample_PRO1322_PlateB_A1$" well_list.txt
# grep "^Sample_PRO1322_PlateB_A1$" well_list_tmp.txt
mv well_list_tmp.txt well_list.txt
# grep "^Sample_PRO1322_PlateB_A1$" well_list.txt

# grep "^Sample_PRO1322_PlateB_A8$" well_list.txt
grep -v "^Sample_PRO1322_PlateB_A8$" well_list.txt > well_list_tmp.txt
# grep "^Sample_PRO1322_PlateB_A8$" well_list.txt
# grep "^Sample_PRO1322_PlateB_A8$" well_list_tmp.txt
mv well_list_tmp.txt well_list.txt
# grep "^Sample_PRO1322_PlateB_A8$" well_list.txt


# make array variable to step through
sample_info=well_list.txt # put folderlist.txt into variable
# e.g. # PKG-ENQ-1643-Data_Transfer-PSEQ-1600_2_lanes/Sample_PRO1322_PlateB_G4q
sample_names=($(cut -f 1 "$sample_info" | sort | uniq)) # convert variable to array this way.  N.B. must sort before uniq
# echo "${sample_names[@]}" # echo all array elements
echo "There are" ${#sample_names[@]} "folders that will be processed." # echo number of elements in the array

# GNU Parallel version
PATH=$PATH:~/scripts/parallel-20170722/bin/
parallel --progress "mkdir ${COMBINEDFASTQ}_combined/{}; \
     cat PKG*/BWA*/{}/*_R1_val_1.fq.gz > ${COMBINEDFASTQ}_combined/{}/{}_R1_val_1.fq.gz; \
     cat PKG*/BWA*/{}/*_R2_val_2.fq.gz > ${COMBINEDFASTQ}_combined/{}/{}_R2_val_2.fq.gz" \
     ::: "${sample_names[@]}" # > paralleltest.txt

# loop version
# for sample in "${sample_names[@]}"  # ${sample_names[@]} is the full bash array
# do
# 	cd ${HOMEFOLDER} || exit
# 	echo "Now on Sample ${INDEX} of ${#sample_names[@]}:"
# 	INDEX=$((INDEX+1))
#
#      SAMPLEBASE=$(basename ${sample}) # remove the PKG-ENQ-*lanes/. enclosing folder name from ${sample}  # this isn't necessary since i removed basenames above, but it does no harm, and i keep it so i don't have to rewrite the code below
#      echo "**** combining ${SAMPLEBASE} R{1,2}_val_{1,2}.fq.gz files to working folder"
#      # this cats all fastq.gz files that have the same ${sample} name EVEN IF in different folders
#      mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE} # make folder to contain combined fastq files for this ${sample} inside platesA2B2_combined/
#      echo "**** mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE}"
#           # enclosing folder 1: PKG_platesA2B2_combined_Lanes1_10
#           # enclosing folder 2: PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane
#           # filename format 1:  PRO1322_PlateB_H11_ACTATTCCA-TGGAAT_L003_R1_val_1.fq.gz
#           # filename format 2:  PRO1322_PlateB_H11_ACTATTCCA-TGGAAT_L003_R2_val_2.fq.gz
#      cat PKG*/BWA*/${SAMPLEBASE}/*_R1_val_1.fq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R1_val_1.fq.gz
#      cat PKG*/BWA*/${SAMPLEBASE}/*_R2_val_2.fq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R2_val_2.fq.gz
# done

echo "Pipeline started at $PIPESTART"
NOW=$(date)
echo "Pipeline ended at   $NOW"


# $HOMEFOLDER: /gpfs/home/b042/greenland_2017/platesA2B2
# ${COMBINEDFASTQ}_combined:  platesA2B2_combined
# ${sample}:  PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes/Sample_PRO1322_PlateA_E6
# ${SAMPLEBASE}:  Sample_PRO1322_PlateA_E6
# ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}_R1.fastq.gz:
# /gpfs/home/b042/greenland_2017/platesA2B2/platesA2B2_combined/Sample_PRO1322_PlateA_E6_R1.fastq.gz

# PRO1322_PlateA_A1_CGGTTGGTT-AACCAACCG_L007_R1.fastq.gz

# PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes/Sample_PRO1322_PlateA_E6/PRO1322_PlateA_E6_CTTACTGAG-CTCAGTAAG_L001_R2.fastq.gz PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes/Sample_PRO1322_PlateA_E6/PRO1322_PlateA_E6_CTTACTGAG-CTCAGTAAG_L002_R2.fastq.gz PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes/Sample_PRO1322_PlateA_E6/PRO1322_PlateA_E6_CTTACTGAG-CTCAGTAAG_L003_R2.fastq.gz PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes/Sample_PRO1322_PlateA_E6/PRO1322_PlateA_E6_CTTACTGAG-CTCAGTAAG_L004_R2.fastq.gz
# PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes/Sample_PRO1322_PlateA_E6/PRO1322_PlateA_E6_CTTACTGAG-CTCAGTAAG_L005_R2.fastq.gz PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes/Sample_PRO1322_PlateA_E6/PRO1322_PlateA_E6_CTTACTGAG-CTCAGTAAG_L006_R2.fastq.gz PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes/Sample_PRO1322_PlateA_E6/PRO1322_PlateA_E6_CTTACTGAG-CTCAGTAAG_L007_R2.fastq.gz PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes/Sample_PRO1322_PlateA_E6/PRO1322_PlateA_E6_CTTACTGAG-CTCAGTAAG_L008_R2.fastq.gz
