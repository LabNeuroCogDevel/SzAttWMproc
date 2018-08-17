#!/usr/bin/env bash

# build timeseires for each subject, each roi, and each run

[ ! -d roi_ts ] && mkdir roi_ts

for r in $(cat txt/rois.txt); do
  roimask="/Volumes/Phillips/P5/DUP/DUP_PPI/ROIs/${r}.nii.gz"
  [ ! -r $roimask ] && echo "no roi $roimask" && continue

  for ld8 in $(cat txt/complete_controls.txt); do
     for run in 1 2; do
        output=roi_ts/${ld8}_${r}_wm$run.txt 
        [ -r $output ] && echo "have $output" && continue
        input=/Volumes/Phillips/P5/subj/${ld8}/preproc/working*memory_$run/nfswudktm_working*memory_${run}_5.nii.gz
        [ ! -r $input ] && echo "cannot find $input" && continue
        fslmeants -i $input  -o $output -m $roimask
     done
   done
done
