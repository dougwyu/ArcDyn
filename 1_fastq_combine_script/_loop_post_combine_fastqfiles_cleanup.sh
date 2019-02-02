#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to clean up files after running all the _loop_combine_fastqfiles scripts
#######################################################################################
#######################################################################################

# remove folders containing non-combined fastq files in PlatesA2B2/
cd ~/_ArcDyn/
ls
# rm -rf PlatesA2B2/PKG-ENQ-1643-Data_Transfer-PSEQ-1600_2_lanes
# rm -rf PlatesA2B2/PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes
# rm -rf PlatesA2B2/PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lanes # i changed 'lane' to 'lanes' in previous script


# remove folders containing non-combined fastq files in PlatesAB/
cd ~/_ArcDyn/
ls
# rm -rf PlatesAB/Earlham_soups/86ec5e5c-3f7a-49f7-b485-c47afbe526dc/
# rm -rf PlatesAB/Earlham_soups/99cf3d32-58f4-4064-a4ef-44128375cba0/
# rm -rf PlatesAB/Earlham_soups/f16a1625-300b-4746-bfa3-61bbb36634d6/
# rm -rf PlatesAB/Earlham_soups

# remove folders containing non-combined fastq files in PlatesEF/
cd ~/_ArcDyn/
ls
# rm -rf PlatesEF/Earlham_soups_20170603/170421_D00534_0170_ACAU8NANXX_PSEQ_1408/
# rm -rf PlatesEF/Earlham_soups_20170603/170503_D00534_0171_ACAUJ2ANXX_PSEQ_1429/
# rm -rf PlatesEF/Earlham_soups_20170603/170511_D00534_0173_ACAVKNANXX_PSEQ_1436/
# rm -rf PlatesEF/Earlham_soups_20170603/170518_D00534_0174_BCB10GANXX_PSEQ_1437/
# rm -rf PlatesEF/Earlham_soups_20170603

# remove folders containing non-combined fastq files in PlatesGH/
cd ~/_ArcDyn/
ls
# rm -rf PlatesGH/PKG-ENQ-2379-Data_Transfer-PSEQ-1586-trimmed/
# rm -rf PlatesGH/PKG-ENQ-2379-Data_Transfer-PSEQ-1600/
# rm -rf PlatesGH/PKG-ENQ-2379-Data_Transfer-PSEQ-1603/
