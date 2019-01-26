#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to calculate total number of reads per sample
#######################################################################################
#######################################################################################

# Usage: run the commmands interactively

# run this on hpc (i ran these four commands in parallel in multiple terminal windows)
# opt-cmd-return to send to Terminal console
ssh hpc
interactive
PATH=$PATH:~/scripts/
seqkit # chk that command is working

cd ~/ArcDyn # go to root folder and run these commands sequentially
# run in separate windows because each takes around 2 hours to run

# PlatesA2B2
nohup seqkit stats /PlatesA2B2/PlatesA2B2_combined/BWA*/Sample*/Sample*fq.gz > fastq_read_counts_PlatesA2B2.txt &

# PlatesAB
nohup seqkit stats /PlatesAB/PlatesAB_combined/BWA*/Sample*/Sample*fq.gz > fastq_read_counts_PlatesAB.txt &

# PlatesEF
nohup seqkit stats /PlatesEF/PlatesEF_combined/BWA*/Plate*/Plate*fq.gz > fastq_read_counts_PlatesEF.txt &

# PlatesGH
nohup seqkit stats /PlatesGH/PlatesGH_combined/BWA*/Sample*/Sample*fq.gz > fastq_read_counts_PlatesGH.txt &

# download to local folders for each RUN
