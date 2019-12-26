#!/usr/bin/env bash

###
# 03_maxMask_compare_pts_controls.bash  --background connectivity group level analysis from each participant's peak dlpfc ROI connectivity with background exec hippocamp mask
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


cd $(dirname $0)


# a list of masks
MASKLIST=dlpfcMaskList.lst

#exec hippo mask
execHippoMask=BIN_EXEC_HIPPO_converted+tlrc.

cat $MASKLIST| while read mask;do
# for ROI in $(cat $MASKLIST); do

    echo "*******************************************************************************************************PROCESSING ${mask:6:1}"
 
    #subject files for specific ROI
    patients=/Volumes/Phillips/P5/DUP/seed_fc/subjs/1*_2*/1*_${mask:6:1}dlpfc_execHippo_backgroundWM_corrmap_z.nii.gz

    #controls
    controls=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/1*_2*/1*_${mask:6:1}dlpfc_execHippo_backgroundWM_corrmap_z.nii.gz

    #output file name
    name=/Volumes/Phillips/P5/DUP/seed_fc/groupROIanalyses/${mask:6:1}dlpfc_execHippo_backgroundWM_pt_control_compare

    3dttest++ -prefix ${name} -mask $execHippoMask -setA ${patients} -setB ${controls}
 
 
    done

 echo "done."
