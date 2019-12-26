#!/usr/bin/env bash

###
# 01_connectivity.bash  --Goda attempt at connectivity analysis 
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


#NOTE: edited 5/17/2018 to work for GP parcellation seeds
#NOTE: edited 6/22/2018 to work for added patients

cd $(dirname $0)


# a list of subjects
#DUPLIST=DUP.lst
#CONLIST=Controls.lst
NEWPTSLIST=addPatients.lst

# a list of masks
MASKLIST=GPmasks.lst

# brain mask
brainmask=/Volumes/Phillips/P5/DUP/seed_fc/striatal_seeds_2.3m/mni_icbm152_t1_tal_nlin_asym_09c.nii.gz


#PATIENTS
#cat $DUPLIST | while read subj dup; do
cat $NEWPTSLIST | while read subj;do

 restfile=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/brnswudktm_rest_5.nii.gz 

  # test if file does not exist -- when it doesnt say so and go to next id (continue)
  if [ ! -r $restfile ]; then 
     echo "cannot find $restfile" 
     continue
  fi

  echo "processing $subj"

  for ROI in $(cat $MASKLIST); do
     
     ROImask=/Volumes/Phillips/P5/DUP/seed_fc/GP_parcellationseeds_postICA/${ROI}+tlrc.HEAD

     # mask ave
     3dmaskave -q -mask $ROImask $restfile > /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI:0:4}_parc.txt
 
     oneD=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI:0:4}_parc.txt 

     # correlation (3d)
     3dTcorr1D -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI:0:4}_parc_corrmap_r.nii -mask $brainmask $restfile $oneD 

     corrmap=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI:0:4}_parc_corrmap_r.nii.gz

     3dcalc -a $corrmap -expr 'log((1+a)/(1-a))/2' -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI:0:4}_parc_corrmap_z.nii
 
done
  done

#CONTROLS
#cat $CONLIST | while read subj; do
#  restfile=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/brnswudktm_rest_5.nii.gz 
#
#  # test if file does not exist -- when it doesnt say so and go to next id (continue)
#  if [ ! -r $restfile ]; then 
#     echo "cannot find $restfile" 
#     continue
#  fi
#
#  echo "processing $subj"
#
#  for ROI in $(cat $MASKLIST); do
     
#     ROImask=/Volumes/Phillips/P5/DUP/seed_fc/GP_parcellationseeds_postICA/${ROI}+tlrc.HEAD

     # mask ave
#     3dmaskave -q -mask $ROImask $restfile > /Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${ROI:0:4}_parc.txt
 
#     oneD=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${ROI:0:4}_parc.txt 

     # correlation (3d)
#     3dTcorr1D -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${ROI:0:4}_parc_corrmap_r.nii -mask $brainmask $restfile $oneD 

#     corrmap=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${ROI:0:4}_parc_corrmap_r.nii.gz

#     3dcalc -a $corrmap -expr 'log((1+a)/(1-a))/2' -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${ROI:0:4}_parc_corrmap_z.nii
 

#  done

#done
 echo "done."
