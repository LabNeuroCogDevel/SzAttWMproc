#!/usr/bin/env bash

#03_GP_patients_controls.bash - 3dttest comapring controls and patient GP connectivity

#NOTE: edited 07/02/2018 not clust sim rn
#NOTE: edited 6/29/2018 to include added patients and Control activation mask
#NOTE: edited 5/17/2018 for GP seeds from parcellation

cd $(dirname $0)

#a list of masks
MASKLIST=GPmasks.lst

#mask=/Volumes/Phillips/P5/DUP/seed_fc/hubs/resamp_MNI152_GM_MASK_bin.nii.gz
mask=/Volumes/Phillips/P5/DUP/seed_fc/groupROIanalyses/Control_GP_mask+tlrc

cat $MASKLIST| while read ROI; do
   
   #output file name
#   name=../groupROIanalyses/${ROI}_parc_pt_control_compare_CLUSTSIM_HEAD_addedPTS_2
   name=../groupROIanalyses/${ROI}_parc_pt_control_compare_addedPTS

   #patient files
   patients=../subjs/1*_2*/1*_${ROI}_parc_corrmap_z+tlrc.HEAD

   #control files
   controls=../subjs/Controls/1*_2*/1*_${ROI}_parc_corrmap_z+tlrc.HEAD

#   3dttest++ -prefix $name -mask $mask -Clustsim -setA $patients -setB $controls
  3dttest++ -prefix $name -mask $mask -setA $patients -setB $controls

done
echo "done."
