#!/bin/bash
set -e
set -u
set -o pipefail
#######################################################################################
#######################################################################################
# a shell script to rename the multiqc outputs
#######################################################################################
#######################################################################################

cd ~/ArcDyn/PlatesA2B2/
RUN="A2B2"
echo ${RUN}
mv multiqc_report.html multiqc_report_${RUN}.html
mv multiqc_data multiqc_data_${RUN}
ls

cd ~/ArcDyn/PlatesAB/
RUN="AB"
echo ${RUN}
mv multiqc_report.html multiqc_report_${RUN}.html
mv multiqc_data multiqc_data_${RUN}
ls

cd ~/ArcDyn/PlatesEF/
RUN="EF"
echo ${RUN}
mv multiqc_report.html multiqc_report_${RUN}.html
mv multiqc_data multiqc_data_${RUN}
ls

cd ~/ArcDyn/PlatesGH/
RUN="GH"
echo ${RUN}
mv multiqc_report.html multiqc_report_${RUN}.html
mv multiqc_data multiqc_data_${RUN}
ls
