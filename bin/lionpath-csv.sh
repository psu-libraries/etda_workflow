#!/bin/bash

PATTERN=$1

if [ $HOSTNAME = 'etdaworkflow1prod' ]; then
  ID_FILE_PATH='~/.ssh/id_rsa_lionpath_prod'
  EXT_HOST='uldsrdc@prod-nfs.lionpath.psu.edu'
else
  ID_FILE_PATH='~/.ssh/id_rsa_lionpath_test'
  EXT_HOST='uldsrdc@qna-nfs.lionpath.psu.edu'
fi

# Using SFTP connection with LionPATH host to pull file names in order of most to least recent
OUTPUT=$(sftp -P 22 -b bin/lp_sftp_newest.bat -i $ID_FILE_PATH $EXT_HOST)

# Single out the first file that matches $PATTERN and pull this down as tmp/lionpath.csv
for x in $OUTPUT
do
  if [[ "$x" =~ "$PATTERN" ]]; then
    sftp -P 22 -r -i $ID_FILE_PATH $EXT_HOST:/out/$x tmp/lionpath.csv
    break
  fi
done
