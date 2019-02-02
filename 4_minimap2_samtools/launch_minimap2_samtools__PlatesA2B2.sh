PlatesA2B2_combined#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to launch bsub files.
#######################################################################################
#######################################################################################

# upload (scp) the new minimap and samtools sh and bsub files to ArcDyn/PlatesA2B2
# run in macOS, not hpc
# scp /Users/Negorashi2011/Dropbox/Working_docs/Roslin_Greenland/2017/bulk_samples/ArcDyn_scripts/4_minimap2_samtools/_loop_minimap2_only_20190115.sh b042@hpc.uea.ac.uk:~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/
# scp /Users/Negorashi2011/Dropbox/Working_docs/Roslin_Greenland/2017/bulk_samples/ArcDyn_scripts/4_minimap2_samtools/_loop_minimap2_only_20190115.bsub b042@hpc.uea.ac.uk:~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/
#
# scp /Users/Negorashi2011/Dropbox/Working_docs/Roslin_Greenland/2017/bulk_samples/ArcDyn_scripts/4_minimap2_samtools/_loop_samtools_only_20190115.sh b042@hpc.uea.ac.uk:~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/
# scp /Users/Negorashi2011/Dropbox/Working_docs/Roslin_Greenland/2017/bulk_samples/ArcDyn_scripts/4_minimap2_samtools/_loop_samtools_only_20190115.bsub b042@hpc.uea.ac.uk:~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/

############# edit minimap2 and samtools scripts #############
# ssh hpc
# interactive
# to use parallel without a pathname in bsub scripts
PATH=$PATH:~/scripts/parallel-20170722/bin/

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/; ls

############## by hand, copy 1/10 the sample folders into each BWA folder
# mkdir BWA{01,02,03,04,05,06,07,08,09,10}; ls # BWA is prefix because this was the original mapping software
# there are 171 sample folders:  hand move 17 into each BWA folder (easier than writing a script)

############# copy the minimap and samtools shell and bsub scripts into each BWA folder and edit the jobIDs
MINIMAP2_BSUB="_loop_minimap2_only_20190115.bsub"; echo ${MINIMAP2_BSUB}
MINIMAP2_SH="_loop_minimap2_only_20190115.sh"; echo ${MINIMAP2_SH}
SAMTOOLS_BSUB="_loop_samtools_only_20190115.bsub"; echo ${SAMTOOLS_BSUB}
SAMTOOLS_SH="_loop_samtools_only_20190115.sh"; echo ${SAMTOOLS_SH}

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined; ls
parallel cp ${MINIMAP2_BSUB} BWA{} ::: 01 02 03 04 05 06 07 08 09 10
parallel cp ${MINIMAP2_SH} BWA{} ::: 01 02 03 04 05 06 07 08 09 10
parallel cp ${SAMTOOLS_BSUB} BWA{} ::: 01 02 03 04 05 06 07 08 09 10
parallel cp ${SAMTOOLS_SH} BWA{} ::: 01 02 03 04 05 06 07 08 09 10
ls BWA{01,02,03,04,05,06,07,08,09,10}

#### only run this if i think that i'm not downloading the latest minimap2/bwa files
# # remove previous bwa_output and minimap2_output files
# parallel "rm -rf BWA{}/bwa_outputs/" ::: 01 02 03 04 05 06 07 08 09 10
# parallel "rm -rf BWA{}/minimap2_outputs/" ::: 01 02 03 04 05 06 07 08 09 10

# edit the bsub files so that the correct jobID will show up (i suppose i could have instead run a job array...)
cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined; ls

parallel "sed 's/mnmploop01/mnmpA2B2{}/g' BWA{}/${MINIMAP2_BSUB} > BWA{}/${MINIMAP2_BSUB}_tmp" ::: 01 02 03 04 05 06 07 08 09 10
parallel "mv BWA{}/${MINIMAP2_BSUB}_tmp BWA{}/${MINIMAP2_BSUB}" ::: 01 02 03 04 05 06 07 08 09 10
head -n7 BWA{01,02,03,04,05,06,07,08,09,10}/${MINIMAP2_BSUB} # check.  should be mnmpA2B2{01,02,03,...}
     # check if i'm using mellanox-ib or short-eth
tail -n2 BWA{01,02,03,04,05,06,07,08,09,10}/${MINIMAP2_BSUB} # check.  should be the correct shell file

parallel "sed 's/samtools01/smtlA2B2{}/g' BWA{}/${SAMTOOLS_BSUB} > BWA{}/${SAMTOOLS_BSUB}_tmp" ::: 01 02 03 04 05 06 07 08 09 10
parallel "mv BWA{}/${SAMTOOLS_BSUB}_tmp BWA{}/${SAMTOOLS_BSUB}" ::: 01 02 03 04 05 06 07 08 09 10
head -n 7 BWA{01,02,03,04,05,06,07,08,09,10}/${SAMTOOLS_BSUB} # check.  should have the correct index number
     # check if i'm using mellanox-ib or short-eth
tail -n 1 BWA{01,02,03,04,05,06,07,08,09,10}/${SAMTOOLS_BSUB} # check.  should have the correct samtools shell filename

ls # BWA* folders should now sort to bottom

####### launch the minimap2 scripts #######
# cd into each BWA folder and submit bsub job
cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA01; ls
bsub < ${MINIMAP2_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA02; ls
bsub < ${MINIMAP2_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA03; ls
bsub < ${MINIMAP2_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA04; ls
bsub < ${MINIMAP2_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA05; ls
bsub < ${MINIMAP2_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA06; ls
bsub < ${MINIMAP2_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA07; ls
bsub < ${MINIMAP2_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA08; ls
bsub < ${MINIMAP2_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA09; ls
bsub < ${MINIMAP2_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA10; ls
bsub < ${MINIMAP2_BSUB}
bjobs

bjobs
bqueues
ls ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA01/minimap2_outputs # check


######  WAIT FOR THE MINIMAP2 JOBS TO FINISH BEFORE LAUNCHING THE SAMTOOLS SCRIPTS
# ssh hpc
# interactive

####### launch samtools scripts #######
cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA01; ls
echo "${SAMTOOLS_BSUB}" # if incorrect or NULL, go up to top of script
bsub < ${SAMTOOLS_BSUB}
bjobs
ls minimap2_outputs # should start to see the new bam files

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA02; ls
bsub < ${SAMTOOLS_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA03; ls
bsub < ${SAMTOOLS_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA04; ls
bsub < ${SAMTOOLS_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA05; ls
bsub < ${SAMTOOLS_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA06; ls
bsub < ${SAMTOOLS_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA07; ls
bsub < ${SAMTOOLS_BSUB}

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA08; ls
bsub < ${SAMTOOLS_BSUB}

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA09; ls
bsub < ${SAMTOOLS_BSUB}

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA10; ls
bsub < ${SAMTOOLS_BSUB}
bjobs

cd ~/_ArcDyn/PlatesA2B2/PlatesA2B2_combined/BWA01
ls minimap2_outputs # should show new bam files
