#!/usr/bin/env bash

###
# 03_ICAcompare.bash  --compare connectivity from different seeds 
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash

# NOTE: edited 5/10/2018 for ICA seeds

cd $(dirname $0)


# a list of masks
#MASKLIST=masks.lst
#MASKLIST=ICAseeds.lst

#NUMS=numbers.lst
NUMBERS=numbers.lst

#cat $MASKLIST| while read ROI;do
# for ROI in $(cat $MASKLIST); do
for NUMS in $(cat $NUMBERS); do

    echo "*******************************************************************************************************PROCESSING ${ROI}"
 
    #list of covariates (DUP,age,sex) 
    #covars=${ROI}_DUP.lst

    #subject files for specific ROI
    setA=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/1*_2*/1*_R${NUMS}_corrmap_z.nii.gz

    setB=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/1*_2*/1*_L${NUMS}_corrmap_z.nii.gz
  
    #output file name
    name=/Volumes/Phillips/P5/DUP/seed_fc/groupROIanalyses/R${NUMS}_L${NUMS}_compare_controls.nii

    #whole brian mask
    brainMask=/Volumes/Phillips/P5/DUP/seed_fc/striatal_seeds_2.3m/mni_icbm152_t1_tal_nlin_asym_09c.nii

    #3dttest++ -prefix ${name} -setA ${setA} -covariates ${covars}  
 
    3dttest++ -prefix ${name} -setA ${setA} -setB ${setB}
 
    done

 echo "done."
