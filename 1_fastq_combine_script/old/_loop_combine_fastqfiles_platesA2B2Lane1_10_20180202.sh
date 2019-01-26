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
# Interactive procedure:  run these commands before running _loop_combine_fastqfiles_20180202.sh interactively
# interactive
# cd into folder holding the fastq files (e.g. ~/greenland_2017/platesA2B2/)
# upload _loop_combine_fastqfiles_20180202.sh into the folder
# bash _loop_combine_fastqfiles_20180202.sh


# PLAN:
  # make list of sample names (the folders for each set of fastq files, corresponding to a single sample/well)
     # for example:
       # ~/greenland_2017/platesA2B2/
       # ~/greenland_2017/platesGH/
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
if [ ! -d "${COMBINEDFASTQ}_combined" ] # if directory pilon_outputs does not exist
then
	mkdir "${COMBINEDFASTQ}_combined"
fi

# these are the two runs for platesA2B2 (as of 20180202, but waiting for last lane)
# platesA2B2/PKG-ENQ-1643-Data_Transfer-PSEQ-1600_2_lanes
# platesA2B2/PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes

# read in folder list and make a bash array
# find * -maxdepth 1 -type d -name "Sample_*" > well_list.txt  # find all folders (-type d) starting with "Sample*". search one level down
find * -maxdepth 1 -type d -name "Sample_*" | sed -E 's/PKG-\w+-\w+-\w+-\w+-\w+lanes//g' | sort | uniq - > well_list.txt  # find all folders (-type d) starting with "Sample*". search one level down.  keep only unique values. N.B. must sort before uniq
# less well_list.txt
# wc -l well_list.txt
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

     SAMPLEBASE=$(basename ${sample}) # remove the PKG-ENQ-*lanes/. enclosing folder name from ${sample}
     echo "**** combining ${SAMPLEBASE} fastq.gz files to working folder"
     # this cats all fastq.gz files that have the same ${sample} name EVEN IF in different PKG-ENQ*lanes folder

     mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE} # make folder to contain combined fastq files for this ${sample}
     echo "**** mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE}"
     cat PKG*lanes/${SAMPLEBASE}/*_R1.fastq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R1.fastq.gz
     cat PKG*lanes/${SAMPLEBASE}/*_R2.fastq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R2.fastq.gz
done

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
