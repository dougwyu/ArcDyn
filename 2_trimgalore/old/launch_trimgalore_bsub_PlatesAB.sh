#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to launch bsub files for trimgalore
#######################################################################################
#######################################################################################

# upload the trimgalore bsub file from macOS
# run in macOS, not hpc
scp ~/Dropbox/Working_docs/Roslin_Greenland/2017/bulk_samples/ArcDyn_scripts/3_trimgalore_minimap2_samtools/loop_trimgalore_20180216.bsub b042@hpc.uea.ac.uk:~/ArcDyn/PlatesAB/PlatesAB_combined/
scp ~/Dropbox/Working_docs/Roslin_Greenland/2017/bulk_samples/ArcDyn_scripts/3_trimgalore_minimap2_samtools/_loop_trimgalore_20180221.sh b042@hpc.uea.ac.uk:~/ArcDyn/PlatesAB/PlatesAB_combined/

############# log into hpc #############
ssh hpc
interactive
# to use parallel without a pathname in bsub scripts
PATH=$PATH:~/scripts/parallel-20170722/bin/

############# put sample files into different subfolders #############
# cd ~/ArcDyn/PlatesAB/PlatesAB_combined/
# mkdir BWA{01,02,03,04,05,06,07,08,09,10} # called BWA because that was what i was originally going to use
# by hand, copy 1/10 the sample files into each BWA folder

############# copy the trimgalore shell and bsub scripts into each BWA folder
TRIMGALORE_BSUB="loop_trimgalore_20190113.bsub"; echo ${TRIMGALORE_BSUB}
TRIMGALORE_SH="loop_trimgalore_20190113.sh"; echo ${TRIMGALORE_SH}

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/; ls
parallel cp ${TRIMGALORE_BSUB} BWA{} ::: 01 02 03 04 05 06 07 08 09 10
parallel cp ${TRIMGALORE_SH} BWA{} ::: 01 02 03 04 05 06 07 08 09 10
ls BWA{01,02,03,04,05,06,07,08,09,10}

# edit the bsub files so that the correct job name will show up
cd ~/ArcDyn/PlatesAB/PlatesAB_combined/; ls

parallel "sed 's/trimgal01/trimAB{}/g' BWA{}/${TRIMGALORE_BSUB} > BWA{}/${TRIMGALORE_BSUB}_tmp" ::: 01 02 03 04 05 06 07 08 09 10
parallel "mv BWA{}/${TRIMGALORE_BSUB}_tmp BWA{}/${TRIMGALORE_BSUB}" ::: 01 02 03 04 05 06 07 08 09 10
head -n7 BWA{01,02,03,04,05,06,07,08,09,10}/${TRIMGALORE_BSUB} # check.  should be trimAB{01,02,03,...}
     # check if i'm using mellanox-ib or short-eth
tail -n2 BWA{01,02,03,04,05,06,07,08,09,10}/${TRIMGALORE_BSUB} # check.  should be the correct shell file
ls # BWA* folders should now sort to bottom


####### launch trimgalore scripts #######
cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA01; ls
bsub < ${TRIMGALORE_BSUB}
bjobs

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA02; ls
bsub < ${TRIMGALORE_BSUB}

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA03; ls
bsub < ${TRIMGALORE_BSUB}
bjobs

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA04; ls
bsub < ${TRIMGALORE_BSUB}

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA05; ls
bsub < ${TRIMGALORE_BSUB}

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA06; ls
bsub < ${TRIMGALORE_BSUB}

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA07; ls
bsub < ${TRIMGALORE_BSUB}

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA08; ls
bsub < ${TRIMGALORE_BSUB}

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA09; ls
bsub < ${TRIMGALORE_BSUB}

cd ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA10; ls
bsub < ${TRIMGALORE_BSUB}
bjobs | sort -k8

ls ~/ArcDyn/PlatesAB/PlatesAB_combined/BWA10/Sample_PRO1322_PlateA_F3 # should show first set of trimmed files
