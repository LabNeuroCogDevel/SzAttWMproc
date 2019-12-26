#!/usr/bin/env bash

#set -euxo pipefail

###
# 03_maxMask_background_minus_rest.bash  - subtracts each participant's whole brain resting state corrmap_z from their whole brain errts corrmap_z 
# 
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


cd $(dirname $0)


# a list of subjects
BACKGROUNDSUBJS=WMall.lst
#CONTROLS=Controls.lst

#  masks (l and r dlpfc)
SIDE=LandR.lst

cat $BACKGROUNDSUBJS | while read subj; do

for side in $(cat $SIDE); do

### determine if patient or control
if grep -Fxq "$subj" WMsubjs.lst

then #if patient


#check if already done
# wholeBrain or execHippo

           3dcalc -a ../subjs/${subj}/${subj:0:5}_${side}dlpfc_wholeBrain_backgroundWM_corrmap_z.nii.gz -b ../subjs/${subj}/${subj:0:5}_${side}dlpfc_wholeBrain_rest_corrmap_z.nii.gz -expr 'a-b' -prefix ../subjs/${subj}/${subj:0:5}_${side}dlpfc_wholeBrain_backgroundWM_minus_rest_corrmap_z.nii.gz



elif grep -Fxq "$subj" WMcontrols.lst #if control
then

      3dcalc -a ../subjs/Controls/${subj}/${subj:0:5}_${side}dlpfc_wholeBrain_backgroundWM_corrmap_z.nii.gz -b ../subjs/Controls/${subj}/${subj:0:5}_${side}dlpfc_wholeBrain_rest_corrmap_z.nii.gz -expr 'a-b' -prefix ../subjs/Controls/${subj}/${subj:0:5}_${side}dlpfc_wholeBrain_backgroundWM_minus_rest_corrmap_z.nii.gz





fi
done
done

echo "done!"
