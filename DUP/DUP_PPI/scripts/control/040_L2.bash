#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

#
# combine runs 1 and 2
#

for ld8 in $(cat txt/complete_controls.txt); do
   for roi in $(cat txt/rois.txt); do
      featdirs=($(find  PPI/$ld8/ -type d -maxdepth 1 -iname "WM*_${roi}_delay_L1_sepload.feat" 2>/dev/null))
      [ ${#featdirs[@]} -ne 2 ] && echo "$ld8 $roi: bad number of feat dirs (${#featdirs[@]}: $featdirs)" && continue
      echo ./L2_feat.bash L2_template.fsf ${featdirs[@]}
   done
done
