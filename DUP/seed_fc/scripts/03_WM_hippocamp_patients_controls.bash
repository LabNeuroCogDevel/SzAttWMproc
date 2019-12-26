#!/usr/bin/env bash

#03_WM_patients_controls.bash - 3dttest comapring controls and patient background working memory connectivity

cd $(dirname $0)

#a list of masks
MASKLIST=hip_dlpfc_masks.lst

cat $MASKLIST| while read ROI; do
   
   #output file name
   name=../groupROIanalyses/${ROI}_backgroundWM_pt_control_compare.nii

   #patient files
   patients=../subjs/1*_2*/1*_${ROI}_backgroundWM_corrmap_z.nii.gz

   #control files
   controls=../subjs/Controls/1*_2*/1*_${ROI}_backgroundWM_corrmap_z.nii.gz

   3dttest++ -prefix $name -setA $patients -setB $controls


done
echo "done."
