#!/usr/bin/env bash

#set -euxo pipefail

###
# 01_maxMask.bash  --gets each participant's max in the BIN_EXEC_HIPPO mask from errts file (background) and makes a  
#
# NOTE: edited 10/18/2018 to make masks for resting state instead of errts 
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


cd $(dirname $0)


# a list of subjects
BACKGROUNDSUBJS="WMsubjs.lst"
CONTROLS=Controls.lst
ADDSUBJS="needMasks.lst"


# executive and hippocampus mask
#execHippoMask=BIN_EXEC_HIPPO_converted+tlrc.
#dlpfcMask=/Volumes/Phillips/P5/DUP/files/Analysis2/DLPFCcombo+tlrc.
MASKLIST=dlpfcMaskList.lst

subbriklist=('delay_ld3#0_Coef' 'delay_ld1#0_Coef')
sbrik_select=$(IFS=,;echo "${subbriklist[*]}")

cat $MASKLIST | while read mask; do
 #  cat $BACKGROUNDSUBJS | while read subj; do
#cat $CONTROLS | while read subj; do
echo "subj mask brik val" > delay_choice.txt
cat $BACKGROUNDSUBJS| while read subj; do
       backgroundFile=/Volumes/Phillips/P5/subj/${subj}/contrasts/WM/stats_WM_final2+tlrc.HEAD

    # timeseries returns entry for each subbrik -- we want overall max
    #maxv=$(3dROIstats -quiet -minmax -mask $execHippoMask $backgroundFile |awk '{print $3}')
    # so get for each subbrik; count lines ($1); get max of max ($4) -- print brik at max
      read brik max  <<< $(3dROIstats -quiet -minmax -mask $mask $backgroundFile"[$sbrik_select]" |cat -n | awk 'BEGIN{m=0} ($4>m){m=$4;n=$1} END{print n-1,m}')
      # 14.644463       -18.759232      55.773151
      # 13.563586       -6.104694       34.074604
      # becomes
      # 0 55.773151
      subbrik_name="${subbriklist[$brik]}"
      echo "max found in $subbriklist ($brik sub brick)"
      echo "$subj $mask $brik $max" |tee -a delay_choice.txt

    #lots of numbers: 3dROIstats -quiet -minmax -mask BIN_EXEC_HIPPO_converted.nii.gz /Volumes/Phillips/P5/subj/11340_20141031/contrasts/WM/errts_WM_final2+tlrc.HEAD |awk '{print $3}'
    # one number:  3dROIstats -quiet -minmax -mask BIN_EXEC_HIPPO_converted.nii.gz /Volumes/Phillips/P5/subj/11340_20141031/contrasts/WM/errts_WM_final2+tlrc.HEAD |cat -n | awk 'BEGIN{m=0} ($4>m){m=$4;n=$1} END{print n-1,m}'

    # 3dCM "3dcalc(-a test.nii.gz -expr step(a- $(3dROIstats -quiet -minmax -mask test_mask.nii.gz  test.nii.gz |awk '{print $3}') ) )"
      3dcalc -a $backgroundFile"[$subbrik_name]" -m $mask -expr "step(a-$max + 0.00001)*m" -prefix ../backgroundMasks/${subj:0:5}_peak_${mask:6:1}.nii.gz -overwrite

      3dBrickStat -non-zero ../backgroundMasks/${subj:0:5}_peak_${mask:6:1}.nii.gz

    # 3dCM peak_mask.nii.gz
      3dCM -local_ijk ../backgroundMasks/${subj:0:5}_peak_${mask:6:1}.nii.gz > ../backgroundMasks/${subj:0:5}_${mask:6:1}_center.txt
      echo "using center $(cat ../backgroundMasks/${subj:0:5}_${mask:6:1}_center.txt)"
      3dUndump -ijk -srad 5 -prefix ../backgroundMasks/${subj:0:5}_${mask:6:1}_roi.nii.gz -master ../backgroundMasks/${subj:0:5}_peak_${mask:6:1}.nii.gz <(cat ../backgroundMasks/${subj:0:5}_${mask:6:1}_center.txt) -overwrite

done
 done
 echo "done."
