#!/usr/bin/env bash


#NOTE: 8/3/2018 to add mean_fd covariate to patients and controls

cd $(dirname $0)

#a list of masks
MASKLIST=GPmasks.lst

cat $MASKLIST| while read ROI; do
   
   #output file name
   name=../groupROIanalyses/${ROI}_parc_pt_control_compare_meanFD

   #mean_fd covariate file
   covars=${ROI}_meanfd.lst

   #patient files
   patients=../subjs/1*_2*/1*_${ROI}_parc_corrmap_z+tlrc.HEAD

   #control files
   controls=../subjs/Controls/1*_2*/1*_${ROI}_parc_corrmap_z+tlrc.HEAD

   3dttest++ -prefix $name -setA $patients -setB $controls -covariates $covars


done
echo "done."
