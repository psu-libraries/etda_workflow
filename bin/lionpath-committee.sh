#!/bin/bash

# Using SFTP connection with Lionpath host, pull all student thesis/dissertation committee files
sftp -P 22 -r -i ~/.ssh/id_rsa_lionpath_prod uldsrdc@prod-nfs.lionpath.psu.edu:/out/PE_SR_G_ETD_COMMITTEE_PRC* var/tmp_lionpath/

# Single out the newest file, rename, and delete the old ones
ls -t var/tmp_lionpath/ | head -1 | xargs -I '{}' mv var/tmp_lionpath/{} var/tmp_lionpath/lionpath.csv
rm var/tmp_lionpath/PE_SR_G_ETD_COMMITTEE_PRC*
