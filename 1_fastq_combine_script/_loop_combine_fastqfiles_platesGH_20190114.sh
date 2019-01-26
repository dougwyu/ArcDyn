#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to loop through a set of fastq files and combine them
#######################################################################################
#######################################################################################

# Usage:
# Interactive procedure:  run these commands before running _loop_combine_fastqfiles_platesGH_20190114.sh interactively
# interactive
# cd into folder holding the fastq files (e.g. ~/ArcDyn/PlatesGH/)
# upload _loop_combine_fastqfiles_platesGH_20190114.sh into the folder
# bash _loop_combine_fastqfiles_platesGH_20190114.sh


# This version is adapted to be able to handle the weird foldernames in PlatesGH/ # one with 'trimmed' at the end
# find * -maxdepth 1 -type d -name "Sample_*" | sed -E 's/PKG-\w+-\w+-\w+-\w+-\w+[-\w+]*//g' | sed -E 's/trimmed//g' | sort | uniq - > well_list.txt

# PLAN:
  # make list of sample names (the folders for each set of fastq files, corresponding to a single sample/well)
     # ~/ArcDyn/PlatesGH/
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
if [ ! -d "${COMBINEDFASTQ}_combined" ] # if directory PlatesGH_combined does not exist
then
	mkdir "${COMBINEDFASTQ}_combined"
fi

# these are the three runs for platesGH
     # PlatesGH/PKG-ENQ-2379-Data_Transfer-PSEQ-1586-trimmed  # the sequencing centre trimmed the first few base pairs of the forward read of this run because there was a quality problem at the beginning of the run.  I am using this file instead of the untrimmed version
     # PlatesGH/PKG-ENQ-2379-Data_Transfer-PSEQ-1600
     # PlatesGH/PKG-ENQ-2379-Data_Transfer-PSEQ-1603

# read in folder list and make a bash array
# find * -maxdepth 1 -type d -name "Sample_*" > well_list.txt  # find all folders (-type d) starting with "Sample*". search one level down
find * -maxdepth 1 -type d -name "Sample_*" | sed -E 's/PKG-\w+-\w+-\w+-\w+-\w+[-\w+]*//g' | sed -E 's/trimmed//g' | sed -E 's/\///g' | sort | uniq - > well_list.txt
# find all folders (-type d) starting with "Sample*". search one level down.  keep only unique values. N.B. must sort before uniq
     # PKG-\w+-\w+-\w+-\w+-\w+[-\w]* # matches these folder names. the [-\w]* is to optionally match -trimmed, where * means 0 or more
          # PKG-ENQ-2379-Data_Transfer-PSEQ-1586-trimmed
          # PKG-ENQ-2379-Data_Transfer-PSEQ-1600
          # PKG-ENQ-2379-Data_Transfer-PSEQ-1603
     # pipe into sed -E 's/trimmed//g' to remove 'trimmed' from the output
     # pipe into sed -E 's/\///g' to remove '/' from the beginning of the sample names
# tail well_list.txt
# head well_list.txt
# wc -l well_list.txt # 190 unique sample names

sample_info=well_list.txt # put folderlist.txt into variable
     # e.g. # PKG-ENQ-1643-Data_Transfer-PSEQ-1600_2_lanes/Sample_PRO1322_PlateB_G4
sample_names=($(cut -f 1 "$sample_info" | sort | uniq)) # convert variable to array this way.  N.B. must sort before uniq
# echo "${sample_names[@]}" # echo all array elements
echo "There are" ${#sample_names[@]} "folders that will be processed." # echo number of elements in the array


for sample in "${sample_names[@]}"  # ${sample_names[@]} is the full bash array
do
	cd ${HOMEFOLDER} || exit
	echo "Now on Sample ${INDEX} of ${#sample_names[@]}. Moved back to starting directory:"
	INDEX=$((INDEX+1))

     SAMPLEBASE=$(basename ${sample}) # not necessary here, but this removes pathname from ${sample}
     echo "**** combining ${SAMPLEBASE} fastq.gz files to working folder"
     # this cats all fastq.gz files that have the same ${sample} name, even if in different PKG-ENQ*/ folders

     mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE} # make folder to contain combined fastq files for this ${sample}
     echo "**** mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE}"
     cat PKG*/${SAMPLEBASE}/*_R1.fastq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R1.fastq.gz
     cat PKG*/${SAMPLEBASE}/*_R2.fastq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R2.fastq.gz
done

echo "Pipeline started at $PIPESTART"
NOW=$(date)
echo "Pipeline ended at   $NOW"


# $HOMEFOLDER: /gpfs/home/b042/ArcDyn/PlatesGH
# ${COMBINEDFASTQ}_combined:  platesGH_combined
# ${sample}:  Sample_PRO1747_PlateG_A1/
# ${SAMPLEBASE}:  Sample_PRO1747_PlateG_A1
# ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R1.fastq.gz:
# /gpfs/home/b042/ArcDyn/PlatesGH/platesGH_combined/Sample_PRO1747_PlateG_A1/Sample_PRO1747_PlateG_A1_R1.fastq.gz

# PRO1747_PlateG_A1_L001_R1.fastq.gz
