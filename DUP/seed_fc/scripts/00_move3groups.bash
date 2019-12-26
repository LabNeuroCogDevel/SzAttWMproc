#!/usr/bin/env bash

cd $(dirname $0)

# where does subject data live?
SUBJROOT=../subjs/


# a list of subjects
SCFULIST=lowerSCFU.lst

# a list of ROIs
GPMASKS=GPmasks.lst

cat $SCFULIST | while read subj; do
 
  echo "Processing $subj"
  
  cat $GPMASKS | while read roi; do

  echo $roi

  file=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${roi}_parc_corrmap_z+tlrc.HEAD

  # test if file does not exist -- when it doesnt say so and go to next id (continue)
  if [ ! -r $file ]; then 
     echo "cannot find $file" 
     continue
     # lesser than 'break'
  fi

  # where are we putting this data
  thissubjdir=$SUBJROOT/lowerSCFU/
  # what to call our newly linked file 
  linkto=$thissubjdir/${subj:0:5}_${roi}_parc_corrmap_z+tlrc.HEAD

  # if we haven't already linked it in, do so
  [ -r $linkto ] && continue

  # make a link to the resting state data
  # we could use cp to make a copy. 
  # but that would take up a lot of disk space and be slow 
  # we are not planing on making any chages to the data
  # we just want it in a new place
  ln -s $file $linkto
done
done
