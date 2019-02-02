#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# PlatesAB:  a shell script to loop through a set of fastq files and combine them because the
# sequencing centre sequenced individual samples (wells) over multiple Illumina runs
#######################################################################################
#######################################################################################

# Usage:
# Interactive procedure:  run these commands before running _loop_combine_fastqfiles_platesAB_20190114.sh interactively
# interactive
# cd into folder holding the fastq files downloaded from Earlham Institute (~/_ArcDyn/PlatesAB/)
# upload _loop_combine_fastqfiles_platesAB_20190114.sh into the folder
# bash _loop_combine_fastqfiles_platesAB_20190114.sh


# PLAN:
  # make list of sample names (the folders for each set of fastq files, corresponding to a single sample/well)
     # for example:  ~/_ArcDyn/PlatesAB/
  # create the Sample_combined folder to hold the new fastq files
  # combine fastq files to the new Sample_combined folder
  # remove the original sample files

# set variables
PIPESTART=$(date)
HOMEFOLDER=$(pwd)
echo "Home folder is ${HOMEFOLDER}"  # Home folder is /gpfs/home/b042/ArcDyn/PlatesAB/
COMBINEDFASTQ=$(basename ${HOMEFOLDER})
echo "COMBINEDFASTQ folder will be ${COMBINEDFASTQ}_combined/"
INDEX=1

# mkdir to hold output
if [ ! -d "${COMBINEDFASTQ}_combined" ] # if directory pilon_outputs does not exist
then
	mkdir "${COMBINEDFASTQ}_combined"
fi

# these are the three sub-runs for platesAB/
# Earlham_soups/99cf3d32-58f4-4064-a4ef-44128375cba0/
# Earlham_soups/86ec5e5c-3f7a-49f7-b485-c47afbe526dc/
# Earlham_soups/f16a1625-300b-4746-bfa3-61bbb36634d6/

# read in folder list and make a bash array
# find * -maxdepth 2 -type d -name "Sample_*" > well_list.txt  # find all folders (-type d) starting with "Sample*". search two levels down (into Earlham_soups/99cf3d32-58f4-4064-a4ef-44128375cba0/ holding the fastq files).  # sed -E 's/Earlham_soups\/[a-z,0-9,-]+\///g' removes the preceding folders: 'Earlham_soups/f16a1625-300b-4746-bfa3-61bbb36634d6/'. The \ escapes the /, allowing it to be read literally. N.B. must sort before uniq.
find * -maxdepth 2 -type d -name "Sample_*" | sed -E 's/Earlham_soups\/[a-z,0-9,-]+\///g' | sort | uniq - > well_list.txt
# less well_list.txt
# tail well_list.txt
# wc -l well_list.txt # 192 unique names because i removed a weird folder Sample_IPO3916_F5_working/ in previous script

sample_info=well_list.txt # put well_list.txt into variable
# e.g. /Sample_PRO1322_PlateA_A1
sample_names=($(cut -f 1 "$sample_info" | sort | uniq)) # convert variable to array this way.  N.B. must sort before uniq
# echo "${sample_names[@]}" # echo all array elements
echo "There are" ${#sample_names[@]} "folders that will be processed." # echo number of elements in the array


for sample in "${sample_names[@]}"  # ${sample_names[@]} is the full bash array
do
	cd ${HOMEFOLDER} || exit
	echo "Now on Sample ${INDEX} of ${#sample_names[@]}. Moved back to starting directory:"
	INDEX=$((INDEX+1))

     SAMPLEBASE=$(basename ${sample}) # not necessary but this removes any enclosing folder names from ${sample}
     echo "**** combining ${SAMPLEBASE} fastq.gz files to working folder"
     # this cats all fastq.gz files that have the same ${sample} name EVEN IF in different PKG-ENQ*lanes folder

     mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE} # make folder to contain combined fastq files for this ${sample}
     echo "**** mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE}"
     cat Earlham_soups/*/${SAMPLEBASE}/*_R1.fastq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R1.fastq.gz
     cat Earlham_soups/*/${SAMPLEBASE}/*_R2.fastq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R2.fastq.gz
done

echo "Pipeline started at $PIPESTART"
NOW=$(date)
echo "Pipeline ended at   $NOW"


# $HOMEFOLDER:  /gpfs/home/b042/ArcDyn/PlatesAB
# ${COMBINEDFASTQ}_combined:  PlatesAB_combined/
# ${sample}:  Sample_PRO1322_PlateA_E6
# ${SAMPLEBASE}:  Sample_IPO3916_A1
# ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}_R1.fastq.gz:
# /gpfs/home/b042/ArcDyn/PlatesAB/PlatesAB_combined/Sample_IPO3916_A1_R1.fastq.gz

# original fastq filename:  IPO3916_A5_CCTCAGAGA-ACAGTG_L001_R1.fastq.gz
