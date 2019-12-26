#!/usr/bin/env bash

#03_controls_GP_striatal.bash - 3dttest comapring control whole brain connectivity for striatal seeds to control whole brain connectivity for GP seeds

#NOTE: rerun 6/27/2018 to include additional patients
#NOTE: edited 5/17/2018 for GP seeds from parcellation

cd $(dirname $0)

#a list of masks
MASKLIST=striatalMasks.lst

cat $MASKLIST| while read ROI; do
   
   #output file name
   name=../groupROIanalyses/${ROI}_${ROI:0:1}GPe_controlsOnly

   #patient files
   striatal=../subjs/Controls/1*_2*/1*_${ROI}_corrmap_z.nii.gz

   #control files
   GP=../subjs/Controls/1*_2*/1*_${ROI:0:1}GPe_parc_corrmap_z.nii.gz

   3dttest++ -prefix $name -setA $GP -setB $striatal


done
echo "done."
