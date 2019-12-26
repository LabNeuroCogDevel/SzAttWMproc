#!/usr/bin/env bash

###
#01_WM_connectivity.bash  -connectivity analysis for background WM data with hippocampal and DLPFC seeds
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash

#NOTE: edited 7/11/2018 to add SZ and affective patients

cd $(dirname $0)


# a list of subjects
#DUPLIST=DUP.lst 
#CONLIST=Controls.lst
ADDSZ=addSZpatients.lst
AFFECTIVE=affective.lst

# a list of masks
MASKLIST=hip_dlpfc_masks.lst

# brain mask
brainmask=/Volumes/Phillips/P5/DUP/seed_fc/striatal_seeds_2.3m/mni_icbm152_t1_tal_nlin_asym_09c.nii

#cat $CONLIST | while read subj; do
cat $AFFECTIVE | while read subj; do 
 restfile=/Volumes/Phillips/P5/subj/${subj}/contrasts/WM/errts_WM_final2+tlrc.HEAD

  # test if file does not exist -- when it doesnt say so and go to next id (continue)
  if [ ! -r $restfile ]; then 
     echo "*****************************************************************************************************cannot find $restfile" 
     continue
  fi

  echo "******************************************************************************************************processing $subj"

  for ROI in $(cat $MASKLIST); do

     if [[ $ROI = *DLPFC_BA* ]] || [[$ROI =~ *CING ]];then 
         ROImask=/Volumes/Phillips/P5/DUP/files/Analysis2/${ROI}+tlrc.HEAD
     fi

     if [[ $ROI = *hippocampus ]];then
         ROImask=/Volumes/Phillips/P5/DUP/seed_fc/hippocampus_seeds/${ROI}+tlrc.HEAD
     fi

     # mask ave
     3dmaskave -q -mask $ROImask $restfile > /Volumes/Phillips/P5/DUP/seed_fc/subjs/Other/$subj/${subj:0:5}_${ROI}_backgroundWM.txt
 
     oneD=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Other/$subj/${subj:0:5}_${ROI}_backgroundWM.txt 

     # correlation (3d)
     3dTcorr1D -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/Other/$subj/${subj:0:5}_${ROI}_backgroundWM_corrmap_r.nii -mask $brainmask $restfile $oneD 

     corrmap=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Other/$subj/${subj:0:5}_${ROI}_backgroundWM_corrmap_r.nii.gz

     3dcalc -a $corrmap -expr 'log((1+a)/(1-a))/2' -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/Other/$subj/${subj:0:5}_${ROI}_backgroundWM_corrmap_z.nii
  done 
done

#cat $DUPLIST | while read subj dupval; do
cat $ADDSZ | while read subj; do
  restfile=/Volumes/Phillips/P5/subj/${subj}/contrasts/WM/errts_WM_final2+tlrc.HEAD
                                                                                                                                                                  
  # test if file does not exist -- when it doesnt say so and go to next id (continue)                                                                              
  if [ ! -r $restfile ]; then 
     echo "*****************************************************************************************************cannot find $restfile" 
     continue
  fi

  echo "******************************************************************************************************processing $subj"

  for ROI in $(cat $MASKLIST); do
         if [[ $ROI = *DLPFC_BA* ]] || [[$ROI =~ *CING ]];then
             ROImask=/Volumes/Phillips/P5/DUP/files/Analysis2/${ROI}+tlrc.HEAD
         fi
    
         if [[ $ROI = *hippocampus ]];then
             ROImask=/Volumes/Phillips/P5/DUP/seed_fc/hippocampus_seeds/${ROI}+tlrc.HEAD
         fi

     # mask ave
     3dmaskave -q -mask $ROImask $restfile > /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_backgroundWM.txt
 
     oneD=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_backgroundWM.txt 

     # correlation (3d)
     3dTcorr1D -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_backgroundWM_corrmap_r.nii -mask $brainmask $restfile $oneD 

     corrmap=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_backgroundWM_corrmap_r.nii.gz

     3dcalc -a $corrmap -expr 'log((1+a)/(1-a))/2' -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${ROI}_backgroundWM_corrmap_z.nii

  done
done  
