#!/usr/bin/env bash

#03_2GP_patients_controls.bash - 3dttest comapring controls and patient connectivity in ROIs of interest discovered after first pass GP connectivity analyses revealed patients and controls had significantly different connectivity between LGPi and these ROIs.

cd $(dirname $0)

#a list of masks
MASKLIST=2GPmasks.lst

cat $MASKLIST| while read ROI; do
   
   #output file name
   name=/Volumes/Phillips/P5/DUP/seed_fc/groupROIanalyses/${ROI}_pt_control_compare.nii

   #patient files
   patients=/Volumes/Phillips/P5/DUP/seed_fc/subjs/1*_2*/1*_${ROI}_corrmap_z.nii.gz

   #control files
   controls=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/1*_2*/1*_${ROI}_corrmap_z.nii.gz

   3dttest++ -prefix $name -setA $patients -setB $controls


done
echo "done."
