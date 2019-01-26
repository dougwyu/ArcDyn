#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to loop through a set of fastq files and run minimap2, samtools, bedtools
#######################################################################################
#######################################################################################

# Usage: bash _loop_minimap2_only_20190115.sh
# this version uses the 308 mitogenome reference fasta or the COI barcode fasta

# Interactive procedure:  first run these commands if running _loop_minimap2_20180122.sh interactively
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
     ######### _loop_minimap2_only_20190115.bsub ##############################################################################
     #######################################################################################
     # #!/bin/sh
     # #BSUB -q short-ib     #long-ib & mellanox-ib (168 hours = 7 days), short-ib (24 hours)
     # #BSUB -J mnmploop01
     # #BSUB -oo mnmploop01.out
     # #BSUB -eo mnmploop01.err
     # #BSUB -R "rusage[mem=125000]"  # set at 125000 for the max (n.b. short-ib, long-ib, mellanox-ib)
     # #BSUB -M 125000
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
     # PATH=$PATH:~/scripts/bwa_0.7.17_r1188 # made 22 Jan 2018 from github
     # PATH=$PATH:~/scripts/bfc/ # r181 # made 3 Aug 2015 from github
     # PATH=$PATH:~/scripts/vsearch-2.6.2-linux-x86_64/bin/ # downloaded 22 Jan 2018 from github
     # PATH=$PATH:~/scripts/TrimGalore-0.4.5/ # downloaded 22 Jan 2018 from github
     # PATH=$PATH:~/scripts/minimap2/  # made 22 Jan 2018 from github 2.7-r659-dirty
     # PATH=$PATH:~/scripts/bedtools2/bin # made 22 Jan 2018 from github 2.27.1
     #
     #
     # bash _loop_minimap2_only_20190115.sh
     #######################################################################################
     #######################################################################################

# SCRIPT OUTLINE:
     # make list of folders
     # loop through folder names for each SAMPLE
     # move trimmed fastq files from $SAMPLE name folder to a working folder
     # run minimap2, and samtools view -b, samtools sort, samtools index, and samtools flagstat
     # move the outputs to minimap2_outputs
     # rm working folder
     # next folder

PIPESTART=$(date)

# upload _loop_minimap2_only_20190115.sh *into* folder that contains the sample folders that i want to map
# when i have lots of sample files, i break it up by putting the sample files into BWA**/ folders and running these scripts inside each one
HOMEFOLDER=$(pwd) # this sets working directory to that folder
echo "Home folder is ${HOMEFOLDER}"

# set variables
INDEX=1
if [ ! -d minimap2_outputs ] # if directory minimap2_outputs does not exist.  this is within the HOMEFOLDER
then
	mkdir minimap2_outputs
fi

# read in folder list and make a bash array
# run inside each BWA folder
##### for Plates E and F, the folders are called Plate{E,F}*, so i change "Sample_*" to "Plate*"
find * -maxdepth 0 -type d -name "Sample_*" > folderlist.txt  # find all folders (-type d) starting with "Sample*"
     # head folderlist.txt
     # tail folderlist.txt
     # wc -l folderlist.txt
sample_info=folderlist.txt # put folderlist.txt into variable
sample_names=($(cut -f 1 "$sample_info" | uniq)) # convert variable to array this way
# echo "${sample_names[@]}" # echo all array elements
echo "There are" ${#sample_names[@]} "folders that will be processed." # echo number of elements in the array

for sample in "${sample_names[@]}"  # ${sample_names[@]} is the full bash array
do
     cd "${HOMEFOLDER}"
     echo "Now on Sample" ${INDEX} of ${#sample_names[@]}". Moved back to starting directory $(date):"
     INDEX=$((INDEX+1))
     # pwd
     FOLDER="${sample}" # this sets the folder name to the value in the bash array (which is a list of the folders)
     echo "**** Working folder is" $FOLDER

     mkdir _${sample}_working

     echo "**** copying trimmed fastq.gz files to working folder $(date)"
     # this makes it easier to clean up if the job is interrupted.  i just rm the working folder
     cp ${FOLDER}/${sample}_R1_val_1.fq.gz "_${sample}_working/"
     cp ${FOLDER}/${sample}_R2_val_2.fq.gz "_${sample}_working/"
     echo "**** trimmed fastq.gz files moved to working folder $(date)"
     cd _${sample}_working; # pwd

     echo "**** start of minimap2, sam to bam conversion, sorting of bam file $(date)"
     #### minimap2 ####
     # minimap2 using preset for Illumina PE reads -x sr and output sam file -a | pipe to samtools sort and output bam file
     # minimap2 -ax sr ref.fa read1.fq read2.fq > aln.sam     # paired-end alignment

     # against 308 full mitogenomes (full sequences, not just protein-coding genes) and 3 COI_spike barcodes
     # minimap2 -t 16 -ax sr ~/ArcDyn/reference_seqs/ArcDyn_308_full_mitogenomes_20180524.fasta ${sample}_R1_val_1.fq.gz ${sample}_R2_val_2.fq.gz | samtools view -b | samtools sort -@15 - -o ${sample}_sorted.bam

     # against 406 barcodes and 3 COI_spike barcodes
     minimap2 -ax sr ~/ArcDyn/reference_seqs/ArcDyn_406_COI_3spikes_20180726.fasta ${sample}_R1_val_1.fq.gz ${sample}_R2_val_2.fq.gz | samtools view -b | samtools sort -@27 - -o ${sample}_sorted.bam

     # against 308 full mitogenomes (full seqs, not just protein-coding genes), 41 COI+CYTB seqs, and 3 COI_spike barcodes
     # minimap2 -t 16 -ax sr ~/ArcDyn/reference_seqs/ArcDyn_308_full_mitogenomes_and_41_COI_CYTB_20181109.fasta ${sample}_R1_val_1.fq.gz ${sample}_R2_val_2.fq.gz | samtools view -b | samtools sort -@15 - -o ${sample}_sorted.bam

     echo "**** end of minimap2, sam to bam conversion, sorting of bam file $(date)"

     # calculate flagstats
     samtools flagstat ${sample}_sorted.bam > ${sample}_sorted.bam.flagstat.txt # basic stats

     echo "**** start of samtools filtering of unmapped reads $(date)"
     # filter out unmapped reads and delete original sorted.bam
     samtools view -b -F 0x4 ${sample}_sorted.bam > ${sample}_F0x4_sorted.bam
     rm -f ${sample}_sorted.bam
     samtools index ${sample}_F0x4_sorted.bam # creates ${sample}_F0x4_sorted.bam.bai file
     echo "**** end of samtools filtering of unmapped reads $(date)"

     echo "**** start of moving outputs to minimap2_outputs/ $(date)"
     mv ${sample}_sorted.bam.flagstat.txt ../minimap2_outputs/
     mv ${sample}_F0x4_sorted.bam.bai ../minimap2_outputs/
     mv ${sample}_F0x4_sorted.bam ../minimap2_outputs/
     echo "**** end of moving outputs to minimap2_outputs/ $(date)"

     cd "${HOMEFOLDER}"
     rm -rf "_${sample}_working" # remove the working directory to make space

done

mv folderlist.txt minimap2_outputs/

echo "Pipeline started at $PIPESTART"
NOW=$(date)
echo "Pipeline ended at   $NOW"
