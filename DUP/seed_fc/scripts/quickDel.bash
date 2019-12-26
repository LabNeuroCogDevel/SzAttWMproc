#!/usr/bin/env bash

###
#deletes files created by 01_connectivity - cleans up to start new

cd $(dirname $0)


# a list of subjects
DUPLIST=DUP.lst 

cat $DUPLIST | while read subj dupval; do

  rm /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/subj* 

 echo "done."
 done
