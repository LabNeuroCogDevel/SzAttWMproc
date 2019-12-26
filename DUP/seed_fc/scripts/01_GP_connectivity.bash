#!/usr/bin/env bash

###
# 01_GP_connectivity.bash  --FIRST PASS GPi and GPe connectivity analysis 
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


cd $(dirname $0)


# a list of subjects
#DUPLIST=DUP.lst
DUPLIST=addDUP.lst
CONTROLLIST=Controls.lst

# a list of masks
MASKLIST=GPmasks.lst
STRIATALMASKS=striatalMasks.lst

# brain mask
brainmask=/Volumes/Phillips/P5/DUP/seed_fc/striatal_seeds_2.3m/mni_icbm152_t1_tal_nlin_asym_09c.nii

cat $DUPLIST | while read subj; do
  restfile=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/brnswudktm_rest_5.nii.gz 

  # test if file does not exist -- when it doesnt say so and go to next id (continue)
  if [ ! -r $restfile ]; then 
     echo "cannot find $restfile" 
     continue
  fi

  echo "processing $subj"

  for ROI in $(cat $STRIATALMASKS); do
     
  ROImask=/Volumes/Phillips/P5/DUP/roi_cor_model/striatal_seeds_2.3m/${ROI}.nii.gz

     # mask ave
     3dmaskave -q -mask $ROImask $restfile > /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}.txt
 
     oneD=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}.txt 

     # correlation (3d)
     3dTcorr1D -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_corrmap_r.nii -mask $brainmask $restfile $oneD 

     corrmap=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_corrmap_r.nii.gz

     3dcalc -a $corrmap -expr 'log((1+a)/(1-a))/2' -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_corrmap_z.nii
 

  done


 done
 echo "done."
