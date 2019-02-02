#!/bin/bash
set -e
set -u
set -o pipefail
##################################################################################################
##################################################################################################
# shell commands to move the Amazon-S3-downloaded sequence files to the correct folders, md5sum check them,
# and then untar them.  I run these commands interactively with nohup &. Then i move the downloaded
# Amazon-S3-downloaded files to a temp folder to hold until i don't need them anymore.
# At the end, i will have the folders ready for concatenating with _loop_combine_fastqfiles shell script
##################################################################################################
##################################################################################################

ssh hpc
interactive
cd ~/_ArcDyn/
ls

# checking on nohup jobs
# ps -ef | grep tar # shows PIDs with word 'tar' in them (thus, picks up both md5sum and tar jobs)
# ps -ef | grep md5sum

############### PlatesAB
# md5sums from Amazon Glacier
# 2016-09-20 20:54 425241579520   55597861df107930ae4a881b0e72d288  s3://amazon-glacier-douglasyu/Earlham_soups_20160910.tar

cd ~/_ArcDyn/

# mv PlatesAB sequence files to PlatesAB/, run in another window
mv Earlham_soups_20160910.tar PlatesAB/
ls
cd PlatesAB/; ls
# compare with above values, takes a long time, run in one window
nohup md5sum Earlham_soups_20160910.tar > PlatesAB.md5 & # run in separate window
# takes a long time
nohup tar -xvf Earlham_soups_20160910.tar & # run in separate window

cd ~/_ArcDyn/PlatesAB; ls
cat PlatesAB.md5 # it matches, so i can untar and start working on it
# 55597861df107930ae4a881b0e72d288  Earlham_soups_20160910.tar
rm -rf ~/_ArcDyn/PlatesAB/Earlham_soups/f16a1625-300b-4746-bfa3-61bbb36634d6/Sample_IPO3916_F5_working/ # there is a weird folder with very small files in there. Sample_IPO3916_F5/ is also present, also with small files. This is a failed sample

################ PlatesA2B2
# md5sums from Amazon Glacier
# 2018-01-24 02:52 41757071360   3c00a119246360278361f90e83d75aae  s3://amazon-glacier-douglasyu/PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1600_2_lanes.tar
# 2018-01-24 00:25 217650309120   67c93451465fa5afb0cc341ae6a47c17  s3://amazon-glacier-douglasyu/PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes.tar
# 2018-02-21 19:12 24986681797   bf9cc26c860c52b8ddd26fe2e638cd6a  s3://amazon-glacier-douglasyu/PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane.tar.gz

cd ~/_ArcDyn/

# mv PlatesA2B2 sequence files to PlatesA2B2/, run in another window
mv PlatesA2B2*.tar* PlatesA2B2/
ls
cd PlatesA2B2/; ls
# compare with above values, takes a long time, run in one window
nohup md5sum PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1600_2_lanes.tar PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes.tar PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane.tar.gz > PlatesA2B2.md5 &
# takes a long time, run in separate windows
nohup tar -xvf PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1600_2_lanes.tar &
nohup tar -xvf PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes.tar &
nohup tar -xzvf PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane.tar.gz &

cd ~/_ArcDyn/PlatesA2B2; ls
mv PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lanes # add an 's' to the end of the folder name so that it is easier to grob in the next script
ls PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lanes/ | less # check
cat PlatesA2B2.md5 # it matches, so i can untar and start working on it
# 3c00a119246360278361f90e83d75aae  PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1600_2_lanes.tar
# 67c93451465fa5afb0cc341ae6a47c17  PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes.tar
# bf9cc26c860c52b8ddd26fe2e638cd6a  PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane.tar.gz


################ PlatesEF
# md5sums from Amazon Glacier
# 2017-06-03 18:06 450506629120   6f73bd9257bb54695a7c72c575b3a599  s3://amazon-glacier-douglasyu/Earlham_soups_20170603.tar

cd ~/_ArcDyn/
# mv PlatesEF sequence files to PlatesEF/, run in another window
mv Earlham_soups_20170603.tar PlatesEF/
ls
cd PlatesEF/; ls
# compare with above values, takes a long time, run in separate window
nohup md5sum Earlham_soups_20170603.tar > PlatesEF.md5 & # PID 17526
# extract the files, takes a long time, run in separate window
nohup tar -xvf Earlham_soups_20170603.tar & # PID 17527

cd ~/_ArcDyn/PlatesEF; ls
cat PlatesEF.md5 # it matches, so i can untar and start working on it
# 6f73bd9257bb54695a7c72c575b3a599  Earlham_soups_20170603.tar


################ PlatesGH
# md5sums from Amazon Glacier
# 2018-03-01 16:15 30632110080   88b36a80dbbf9fd8493e4255f7811f0e  s3://amazon-glacier-douglasyu/PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1586-trimmed.tar
# 2018-03-01 13:20 186389913600   0167c4725ff9ac50390127cc6579118c  s3://amazon-glacier-douglasyu/PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1600.tar
# 2018-03-01 15:10 90482073600   e1f1efea1c1feca0976b7df232804c22  s3://amazon-glacier-douglasyu/PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1603.tar

cd ~/_ArcDyn/

# mv PlatesGH sequence files to PlatesGH/
# mkdir PlatesGH/
mv PlatesGH*.tar PlatesGH/
ls
cd PlatesGH/; ls
# compare with above values, takes a long time, run in separate window
nohup md5sum PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1586-trimmed.tar PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1600.tar PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1603.tar > PlatesGH.md5 &
# takes a long time, run in separate windows
nohup tar -xvf PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1586-trimmed.tar &
nohup tar -xvf PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1600.tar &
nohup tar -xvf PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1603.tar &

cat PlatesGH.md5 # they match, so i can untar and start working on them
# 88b36a80dbbf9fd8493e4255f7811f0e  PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1586-trimmed.tar
# 0167c4725ff9ac50390127cc6579118c  PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1600.tar
# e1f1efea1c1feca0976b7df232804c22  PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1603.tar

ps -ef | grep tar # shows PIDs with word 'tar' in them (thus, picks up both md5sum and tar jobs)



################ mv the Amazon Glacier-downloaded tar and md5 files to a folder for temp holding
# cd ~/_ArcDyn/
# mkdir Amazon_archive_files_to_rm_at_end/
# mv PlatesEF/Earlham_soups_20170603.tar Amazon_archive_files_to_rm_at_end/; ls Amazon_archive_files_to_rm_at_end/
# mv PlatesAB/Earlham_soups_20160910.tar Amazon_archive_files_to_rm_at_end/
# mv PlatesA2B2/PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1600_2_lanes.tar Amazon_archive_files_to_rm_at_end/
# mv PlatesA2B2/PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1618_8_lanes.tar Amazon_archive_files_to_rm_at_end/
# mv PlatesA2B2/PlatesA2B2_PKG-ENQ-1643-Data_Transfer-PSEQ-1657_1_lane.tar.gz Amazon_archive_files_to_rm_at_end/
# mv PlatesGH/PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1586-trimmed.tar Amazon_archive_files_to_rm_at_end/
# mv PlatesGH/PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1600.tar Amazon_archive_files_to_rm_at_end/
# mv PlatesGH/PlatesGH_PKG-ENQ-2379-Data_Transfer-PSEQ-1603.tar Amazon_archive_files_to_rm_at_end/
# mv ~/_ArcDyn/amazon-glacier-douglasyu20190113.md5 ~/_ArcDyn/Amazon_archive_files_to_rm_at_end/
# mv ~/_ArcDyn/Plates*/Plates*.md5 ~/_ArcDyn/Amazon_archive_files_to_rm_at_end/
ls ~/_ArcDyn/Amazon_archive_files_to_rm_at_end
