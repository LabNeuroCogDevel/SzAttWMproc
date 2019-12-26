#!/usr/bin/env bash

cd $(dirname $0)

# where does subject data live?
SUBJROOT=../subjs/


# a list of subjects
SUBJS=WMsubjs.lst

# a list of masks
MASKS=hip_dlpfc_masks.lst

cat $SUBJS | while read subj; do
   
  cat $MASKS | while read roi; do


  file=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${roi}_backgroundWM_corrmap_z.nii.gz

  # test if file does not exist -- when it doesnt say so and go to next id (continue)
  if [ ! -r $file ]; then 
     file=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Other/$subj/${subj:0:5}_${roi}_backgroundWM_corrmap_z.nii.gz
     continue
     # lesser than 'break'
  fi

  # where are we putting this data
  thissubjdir=$SUBJROOT/WM_psychosisGroup/
  # what to call our newly linked file 
  linkto=$thissubjdir/${subj:0:5}_${roi}_backgroundWM_corrmap_z.nii.gz

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
