#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# PlatesEF:  a shell script to loop through a set of fastq files and combine them because the
# sequencing centre sequenced individual samples (wells) over multiple Illumina runs
#######################################################################################
#######################################################################################

# Usage: bash _loop_combine_fastqfiles_platesEF_20190114.sh

# Usage:
# Interactive procedure:  run these commands before running _loop_combine_fastqfiles_platesEF_20190114.sh interactively
# interactive
# cd into folder holding the fastq files downloaded from Earlham Institute (~/_ArcDyn/PlatesEF/)
# upload _loop_combine_fastqfiles_platesEF_20190114.sh into the folder
# bash _loop_combine_fastqfiles_platesEF_20190114.sh

# Batch procedure:  bsub script and submit to short-eth queue
	#######################################################################################
	# #######################################################################################
     # #!/bin/sh
     # #BSUB -q short-eth     #debug, short (24 hours), medium (24 hours), long (168 hours = 7 days)
     # #BSUB -J fqCOMBEF
     # #BSUB -oo fqCOMBEF.out
     # #BSUB -eo fqCOMBEF.err
     # #BSUB -R "rusage[mem=12000]"
     # #BSUB -M 12000
     # #BSUB -B        #sends email to me when job starts
     # #BSUB -N        # sends email to me when job finishes
     #
     # . /etc/profile
     # module purge
     #
     # bash _loop_combine_fastqfiles_platesEF_20190114.sh
	#######################################################################################
	#######################################################################################

# PLAN:
  # get name for $SAMPLEname
  # create the new Sample folder
  # combine fastq files to the new Sample folder
  # next SAMPLE

  # upload _loop_combine_fastqfiles_platesEF_20190114.sh to folder ~/_ArcDyn/PlatesEF/

# set variables
PIPESTART=$(date)
HOMEFOLDER=$(pwd)
echo "Home folder is ${HOMEFOLDER}"  # Home folder is /gpfs/home/b042/ArcDyn/PlatesEF/
COMBINEDFASTQ=$(basename ${HOMEFOLDER})
echo "COMBINEDFASTQ folder will be ${COMBINEDFASTQ}_combined/"
INDEX=1

# mkdir to hold output
if [ ! -d PlatesEF_combined ] # if directory does not exist
then
	mkdir PlatesEF_combined
fi

# these are the four sub-runs for platesEF/
# there are no sample subfolders, only fastq files
# Earlham_soups_20170603/170421_D00534_0170_ACAU8NANXX_PSEQ_1408/PlateE_A1_AACCAACCG-GCCAAT_L001_R1.fastq.gz
# Earlham_soups_20170603/170503_D00534_0171_ACAUJ2ANXX_PSEQ_1429/
# Earlham_soups_20170603/170511_D00534_0173_ACAVKNANXX_PSEQ_1436/
# Earlham_soups_20170603/170518_D00534_0174_BCB10GANXX_PSEQ_1437/

# read in all files and make well_list.txt
# find * -maxdepth 2 -type f -name "Sample_*" > well_list.txt  # find all files (-type f) starting with "Plate*". Search two levels down (into Earlham_soups_20170603/170421_D00534_0170_ACAU8NANXX_PSEQ_1408/ holding the fastq files).  # sed -E 's/Earlham_soups_20170603\/\w+\///g' removes the preceding folders: 'Earlham_soups_20170603/170421_D00534_0170_ACAU8NANXX_PSEQ_1408/'. The \ escapes the /, allowing it to be read literally. N.B. must sort before uniq.
find * -maxdepth 2 -type f -name "Plate*" | sed -E 's/Earlham_soups_20170603\/\w+\///g' | sort | uniq - > well_list.txt

# remove the last part of a bunch of filenames (_L001_R1.fastq.gz and _L001_R1.fastq.gz.md5), sort, uniq, and save to well_list2.txt
sed -E 's/_L\w+.fastq.gz.*//g' well_list.txt | sort | uniq > well_list2.txt
# less well_list2.txt
# head well_list2.txt
# tail well_list2.txt
# wc -l well_list2.txt # 192 unique names

# read well list and make a bash array
sample_info=well_list2.txt # put well_list2.txt into variable
sample_names=($(cut -f 1 "$sample_info" | uniq)) # convert variable to array this way
# echo ${sample_names[@]} # echo all array elements
echo "There are" ${#sample_names[@]} "samples that will be processed." # echo number of elements in the array

for sample in "${sample_names[@]}"  # ${sample_names[@]} is the full bash array
do
	cd ${HOMEFOLDER} || exit
	echo "Now on Sample ${INDEX} of ${#sample_names[@]}. Moved back to starting directory:"
	INDEX=$((INDEX+1))

     SAMPLEBASE=$(basename ${sample}) # not necessary but this removes any enclosing folder names from ${sample}
     echo "**** combining ${SAMPLEBASE} fastq.gz files to working folder"

     mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE} # make folder to contain combined fastq files for this ${sample}
     echo "**** mkdir ${COMBINEDFASTQ}_combined/${SAMPLEBASE}"

     # this cats all fastq.gz files that have the same ${sample} name, despite being in different subfolders
     cat Earlham_soups_20170603/*/${SAMPLEBASE}_L00*_R1.fastq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R1.fastq.gz

     cat Earlham_soups_20170603/*/${SAMPLEBASE}_L00*_R2.fastq.gz > ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}/${SAMPLEBASE}_R2.fastq.gz
done


echo "Pipeline started at $PIPESTART"
NOW=$(date)
echo "Pipeline ended at   $NOW"

# $HOMEFOLDER:   /gpfs/home/b042/ArcDyn/PlatesEF
# ${COMBINEDFASTQ}_combined:  PlatesEF_combined/
# ${sample}:  PlateF_G6_CTCTAGGTT-CTTGTA
# ${SAMPLEBASE}:  PlateF_G6_CTCTAGGTT-CTTGTA
# ${HOMEFOLDER}/${COMBINEDFASTQ}_combined/${SAMPLEBASE}_R1.fastq.gz:
# /gpfs/home/b042/ArcDyn/PlatesEF/PlatesEF_combined/PlateF_G6_CTCTAGGTT-CTTGTA_R1.fastq.gz

# original fastq filename:  PlateF_G6_CTCTAGGTT-CTTGTA_L001_R1.fastq.gz
