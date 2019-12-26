#!/usr/bin/env bash

#03_GP_seed_compare - look for differences between GP seeds

#NOTE: edited 10/09/2018 to swap subtractions - added BminusA option

cd $(dirname $0)

#a list of masks
MASKLIST=GPmasks.lst

   
   #output file name
   name=../groupROIanalyses/RGPe_RGPi_parc_seed_compare_controls.nii

   #patient files
   setA=../subjs/Controls/1*_2*/1*_RGPi_parc_corrmap_z.nii.gz

   #control files
   setB=../subjs/Controls/1*_2*/1*_RGPe_parc_corrmap_z.nii.gz

   3dttest++ -prefix $name -setA $setA -setB $setB -BminusA


echo "done."
