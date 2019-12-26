#!/usr/bin/env bash

###
# 02_GP_grouplevel.bash  --background connectivity group level analysis 
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash

#NOTE: edited 7/5/18 to add clustsim

cd $(dirname $0)


# a list of masks
MASKLIST=GPmasks.lst

mask=/Volumes/Phillips/P5/DUP/seed_fc/groupROIanalyses/Control_GP_mask+tlrc

cat $MASKLIST| while read ROI;do
# for ROI in $(cat $MASKLIST); do

    echo "*******************************************************************************************************PROCESSING ${ROI}"
 
    #list of covariates (DUP,age,sex) 
    covars=${ROI}_SCFUscores.lst

    #subject files for specific ROI
    setA=/Volumes/Phillips/P5/DUP/seed_fc/subjs/1*_2*/1*_${ROI}_parc_corrmap_z+tlrc.HEAD

    #output file name
    name=/Volumes/Phillips/P5/DUP/seed_fc/groupROIanalyses/${ROI}_group_covariate_pts_SCFU_CLUSTSIM

    #whole brian mask
    #brainMask=/Volumes/Phillips/P5/DUP/seed_fc/striatal_seeds_2.3m/mni_icbm152_t1_tal_nlin_asym_09c.nii

      

    3dttest++ -prefix ${name} -mask ${mask} -Clustsim -setA ${setA} -covariates ${covars}
 
 
    done

 echo "done."
