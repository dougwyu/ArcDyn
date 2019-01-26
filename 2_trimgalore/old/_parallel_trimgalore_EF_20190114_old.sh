#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to loop through a set of fastq files and run cutadapt
#######################################################################################
#######################################################################################

# Usage: bash _parallel_trimgalore_EF_20190114.sh

# Interactive procedure:  first run these commands if running _loop_trimgalore_20180216.sh interactively
     # interactive -x -R "rusage[mem=20000]" -M 22000  # alternative is:  interactive -q interactive-lm
     # module load samtools # samtools 1.5
     # module load python/anaconda/4.2/2.7 # Python 2.7.12
     # module load java  # java/jdk1.8.0_51
     # module load gcc # needed to run bedtools
     # PATH=$PATH:~/scripts/cutadapt-1.11/build/scripts-2.7
     # PATH=$PATH:~/scripts/bwa_0.7.17_r1188 # made 22 Jan 2018 from github
     # PATH=$PATH:~/scripts/bfc/ # r181 # made 3 Aug 2015 from github
     # PATH=$PATH:~/scripts/vsearch-2.6.2-linux-x86_64/bin/ # downloaded 22 Jan 2018 from github
     # PATH=$PATH:~/scripts/TrimGalore-0.4.5/ # downloaded 22 Jan 2018 from github
     # PATH=$PATH:~/scripts/minimap2/  # made 22 Jan 2018 from github 2.7-r659-dirty
     # PATH=$PATH:~/scripts/bedtools2/bin # made 22 Jan 2018 from github 2.27.1

# Batch procedure:  bsub script and submit to mellanox-ib queue
     ######### _loop_trimgalore_20190113.sh ##############################################################################
     #######################################################################################
     # #!/bin/sh
     # #BSUB -q short-ib     #long-ib & mellanox-ib (168 hours = 7 days), short-ib (24 hours)
     # #BSUB -J trimgal01
     # #BSUB -oo trimgal01.out
     # #BSUB -eo trimgal01.err
     # #BSUB -R "rusage[mem=5000]"  # set at 5000 for the max (n.b. short-ib, long-ib, mellanox-ib)
     # #BSUB -M 5000
     # #BSUB -x # exclusive access to node, should be in anything that is threaded
     # #BSUB -B        #sends email to me when job starts
     # #BSUB -N        # sends email to me when job finishes
     #
     # . /etc/profile
     # module purge
     # module load samtools # samtools 1.5
     # module load python/anaconda/4.2/2.7 # Python 2.7.12
     # module load java  # java/jdk1.8.0_51
     # module load gcc # needed to run bedtools
     # PATH=$PATH:~/scripts/cutadapt-1.11/build/scripts-2.7
     # PATH=$PATH:~/scripts/vsearch-2.6.2-linux-x86_64/bin/ # downloaded 22 Jan 2018 from github
     # PATH=$PATH:~/scripts/TrimGalore-0.4.5/ # downloaded 22 Jan 2018 from github
     # PATH=$PATH:~/scripts/minimap2/  # made 22 Jan 2018 from github 2.7-r659-dirty
     # PATH=$PATH:~/scripts/bedtools2/bin # made 22 Jan 2018 from github 2.27.1
     #
     #
     # bash _loop_trimgalore_20180216.sh
     #######################################################################################
     #######################################################################################

# SCRIPT OUTLINE:
     # make list of sample folders that hold the fastq files
     # cd into each folder that holds a sample's fastq files
     # run trim_galore
     # next folder

PIPESTART=$(date)

# upload _loop_trimgalore_20190114.sh *into* folder that contains the sample folders that i want to map
# when i have lots of sample files, i break it up by putting the sample files into BWA**/ folders and running this script inside each BWA folder, using the script in launch_trimgalore_bsub
HOMEFOLDER=$(pwd) # this sets working directory to a given BWA folder

echo "Home folder is ${HOMEFOLDER}"

# set variables
# INDEX=1
# if [ ! -d minimap2_outputs ] # if directory minimap2_outputs does not exist.  this is within the HOMEFOLDER
# then
# 	mkdir minimap2_outputs
# fi

# read in folder list and make a bash array

##### for Plates E and F, the folders are called Plate{E,F}*, so i need to change "Sample_*" to "Plate*"

find * -maxdepth 0 -type d -name "Plate*" > folderlist.txt  # find all folders (-type d) starting with "Plate*"
sample_info=folderlist.txt # put folderlist.txt into variable
sample_names=($(cut -f 1 "$sample_info" | uniq)) # convert variable to array this way
# echo "${sample_names[@]}" # echo all array elements
echo "There are" ${#sample_names[@]} "folders that will be processed." # echo number of elements in the array


# GNU PARALLEL version, since trimgalore only uses one cpu per job
parallel --progress "echo Now on species {1} of ${#sample_names[@]}; trim_galore --paired --length 100 -trim-n {1}/*_R1.fastq.gz {1}/*_R2.fastq.gz -o {1}" ::: "${sample_names[@]}"
# -o {1} # to write output to sample folder
# --paired --length 100 # remove a paired read if either is less than 100 bp after trimming (default 20)

# mv folderlist.txt minimap2_outputs/

echo "Pipeline started at $PIPESTART"
NOW=$(date)
echo "Pipeline ended at $NOW"
