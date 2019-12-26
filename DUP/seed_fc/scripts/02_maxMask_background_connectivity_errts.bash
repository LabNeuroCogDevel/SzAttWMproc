#!/usr/bin/env bash

#set -euxo pipefail

###
# 02_maxMask.bash  - gets background connectivity between each participant's max dlpfc roi (left and right) and the exec/hippo mask
# 
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


cd $(dirname $0)


# a list of subjects
BACKGROUNDSUBJS=WMall.lst
#CONTROLS=Controls.lst

# executive and hippocampus mask
MASKLIST=dlpfcMaskList.lst
execHippoMask=BIN_EXEC_HIPPO_converted+tlrc.
wholeBrainMask=/Volumes/Phillips/P5/DUP/seed_fc/striatal_seeds_2.3m/mni_icbm152_t1_tal_nlin_asym_09c.nii

cat $BACKGROUNDSUBJS | while read subj; do

for mask in $(cat $MASKLIST); do

### determine if patient or control
if grep -Fxq "$subj" WMsubjs.lst

then #if patient


#check if already done
# wholeBrain or execHippo
      if [ ! -f /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${mask:6:1}dlpfc_wholeBrain_backgroundWM_corrmap_z.nii.gz ]
      then

            backgroundFile=/Volumes/Phillips/P5/subj/${subj}/contrasts/WM/errts_WM_final2+tlrc.HEAD
       
               # mask ave
               if [ ! -f /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${mask:6:1}dlpfc_backgroundWM.txt ]
               then
                  3dmaskave -q -mask ../backgroundMasks/${subj:0:5}_${mask:6:1}_roi.nii.gz $backgroundFile > /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${mask:6:1}dlpfc_backgroundWM.txt
               fi

            oneD=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${mask:6:1}dlpfc_backgroundWM.txt

            # correlation (3d)
            3dTcorr1D -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${mask:6:1}dlpfc_wholeBrain_backgroundWM_corrmap_r.nii -mask $wholeBrainMask $backgroundFile $oneD

            corrmap=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${mask:6:1}dlpfc_wholeBrain_backgroundWM_corrmap_r.nii.gz

            3dcalc -a $corrmap -expr 'log((1+a)/(1-a))/2' -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_${mask:6:1}dlpfc_wholeBrain_backgroundWM_corrmap_z.nii

      fi

elif grep -Fxq "$subj" WMcontrols.lst #if control
then

   if [ ! -f /Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${mask:6:1}dlpfc_wholeBrain_backgroundWM_corrmap_z.nii.gz ]
   then
         backgroundFile=/Volumes/Phillips/P5/subj/${subj}/contrasts/WM/errts_WM_final2+tlrc.HEAD
     
            #mask ave
            if [ ! -f /Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${mask:6:1}dlpfc_backgroundWM.txt ]
            then
               3dmaskave -q -mask ../backgroundMasks/${subj:0:5}_${mask:6:1}_roi.nii.gz $backgroundFile > /Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${mask:6:1}dlpfc_backgroundWM.txt
            fi


           oneD=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${mask:6:1}dlpfc_backgroundWM.txt

           # correlation (3d)
          3dTcorr1D -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${mask:6:1}dlpfc_wholeBrain_backgroundWM_corrmap_r.nii -mask $wholeBrainMask $backgroundFile $oneD

          corrmap=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${mask:6:1}dlpfc_wholeBrain_backgroundWM_corrmap_r.nii.gz
          
          3dcalc -a $corrmap -expr 'log((1+a)/(1-a))/2' -prefix /Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${mask:6:1}dlpfc_wholeBrain_backgroundWM_corrmap_z.nii
fi
fi
done
done
echo "done!"
