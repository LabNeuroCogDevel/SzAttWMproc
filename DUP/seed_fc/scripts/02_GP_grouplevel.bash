#!/usr/bin/env bash

###
# 02_GP_grouplevel.bash  --background connectivity group level analysis 
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


cd $(dirname $0)


# a list of masks
MASKLIST=GPmasks.lst


cat $MASKLIST| while read ROI;do
# for ROI in $(cat $MASKLIST); do

    echo "*******************************************************************************************************PROCESSING ${ROI}"
 
    #list of covariates (DUP,age,sex) 
    covars=${ROI}_DUP_controls.lst

    #subject files for specific ROI
    setA=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/1*_2*/1*_${ROI}_corrmap_z.nii.gz

    #output file name
    name=/Volumes/Phillips/P5/DUP/seed_fc/groupROIanalyses/Controls/${ROI}_CONTROL_group_covariate_DUP_age_sex.nii

    #whole brian mask
    brainMask=/Volumes/Phillips/P5/DUP/seed_fc/striatal_seeds_2.3m/mni_icbm152_t1_tal_nlin_asym_09c.nii

    3dttest++ -prefix ${name} -setA ${setA} -covariates ${covars}  
 
 
    done

 echo "done."
