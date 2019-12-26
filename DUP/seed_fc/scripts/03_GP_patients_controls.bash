#!/usr/bin/env bash

#03_GP_patients_controls.bash - 3dttest comapring controls and patient GP connectivity

#NOTE: rerun 6/27/2018 to include additional patients
#NOTE: edited 5/17/2018 for GP seeds from parcellation

cd $(dirname $0)

#a list of masks
MASKLIST=GPmasks.lst

cat $MASKLIST| while read ROI; do
   
   #output file name
   name=../groupROIanalyses/${ROI}_parc_pt_control_compare_addedpts.nii

   #patient files
   patients=../subjs/1*_2*/1*_${ROI}_parc_corrmap_z.nii.gz

   #control files
   controls=../subjs/Controls/1*_2*/1*_${ROI}_parc_corrmap_z.nii.gz

   3dttest++ -prefix $name -setA $patients -setB $controls


done
echo "done."
