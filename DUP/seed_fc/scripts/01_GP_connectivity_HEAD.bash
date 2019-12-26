#!/usr/bin/env bash

###
# 01_GP_connectivity.bash  --FIRST PASS GPi and GPe connectivity analysis 
#
# this script written to make corrmap_r and corrmap_z files that save as .BRIK and .HEAD files instead of .nii.gz files

#NOTE: edited 6/29/2018 to be done for added patients

cd $(dirname $0)


# a list of subjects
##DUPLIST=DUP.lst 
#CONTROLLIST=Controls.lst
ADDPTSLIST=addSZpatients.lst

# a list of masks
MASKLIST=GPmasks.lst

# brain mask
brainmask=/Volumes/Phillips/P5/DUP/seed_fc/striatal_seeds_2.3m/mni_icbm152_t1_tal_nlin_asym_09c.nii

cat $ADDPTSLIST | while read subj; do
#cat $DUPLIST | while read subj dup; do  
  restfile=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/brnswudktm_rest_5.nii.gz 

  # test if file does not exist -- when it doesnt say so and go to next id (continue)
#  if [ ! -r $restfile ]; then 
#     echo "cannot find $restfile" 
#     continue
#  fi

#  echo "processing $subj"

  for ROI in $(cat $MASKLIST); do
     
#  ROImask=/Volumes/Phillips/P5/DUP/seed_fc/GP_seeds/${ROI}+tlrc.HEAD

     # mask ave
 #    3dmaskave -q -mask $ROImask $restfile > /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_parc.txt
 
     oneD=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_parc.txt 

     # correlation (3d)
     3dTcorr1D -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_parc_corrmap_r+tlrc.HEAD -mask $brainmask $restfile $oneD 

     corrmap=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_parc_corrmap_r+tlrc.HEAD

     3dcalc -a $corrmap -expr 'log((1+a)/(1-a))/2' -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_parc_corrmap_z+tlrc.HEAD
 

  done


 done
 echo "done."
