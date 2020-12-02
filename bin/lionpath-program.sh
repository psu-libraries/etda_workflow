#!/bin/bash

# Using SFTP connection with Lionpath host to pull file names in order of most to least recent
OUTPUT=$(sftp -P 22 -b bin/lp_sftp_newest.bat -i ~/.ssh/id_rsa_lionpath_prod uldsrdc@prod-nfs.lionpath.psu.edu)

# Single out the first PE_SR_G_ETD_STDNT_PLAN_PRC and pull this down as var/tmp_lionpath/lionpath.csv
for x in $OUTPUT
do
  if [[ "$x" =~ "PE_SR_G_ETD_STDNT_PLAN_PRC" ]]; then
    sftp -P 22 -r -i ~/.ssh/id_rsa_lionpath_prod uldsrdc@prod-nfs.lionpath.psu.edu:/out/$x var/tmp_lionpath/lionpath.csv
    break
  fi
done
