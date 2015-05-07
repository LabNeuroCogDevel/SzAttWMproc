#!/usr/bin/env bash

# MJ20150225 modified from 04_ttest_att.bash to make wm ttest file
# ttest for WM
#   * simpledContrasts_2runs_stats+tlrc.HEAD
#     
#
#  save files for each group in ../group_analyses/WM/*.1D
#                 each ttest in ../group_analyses/wm/ttest/$condition/$date_$condition
#
#


set -e
trap '[ "$?" -ne 0 ] && echo "$0 ended with error!"' EXIT 

# which conditions do we want to compare between controls and patients
conditions=""

# we are using the 2.3mm brain in our final fun->mni warp
mask=$HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_mask_2.3mm.nii

# go one directory above this script to get to the main directory
maindir=$(cd $(dirname $0)/..;pwd)

# google doc that has updated information
#MEGDATE MEGID MRDATE MRID Task_Order_CB WM_Response_CB Attention_Subtask_Order LunaCB Cohort  Counts    
#column 5 is MRID
#       10 is cohort
subjtxt="$maindir/scripts/SubjInfoGoogleSheet.txt"




# we want to organize the data, output should go here
pathAnaly="$maindir/group_analyses/WM"
[ ! -d $pathAnaly ] && mkdir -p $pathAnaly

### build cohorts

# clear all cohort files
cut -f10 -d "	" $subjtxt|sed 1d | sort | uniq | while read cohort; do echo -n "" > $pathAnaly/$cohort.1D; done

# (re)build the cohort files
#  - `sed` to remove header from the google doc
#  - `cut` to get MRID (luna_date, column/field 5) and cohort (field 10) 
#  - `echo >>` to write/append each contrast in the approprate cohort text file
sed 1d "$subjtxt" | cut -f5,10 -d"	" | while read MRID cohort; do
 contrastfile="$maindir/subj/$MRID/contrasts/WM/simpledContrasts_2runs_stats+tlrc.HEAD"

 [ ! -r "$contrastfile" ] && 
     echo "SKIPPING $MRID ($cohort): no contrasts file ($contrastfile)" && 
     continue

 echo $contrastfile >> $pathAnaly/$cohort.1D
done




# for each condition we are interseted in
for cond in $conditions; do

  # define where to save the ttest output
  # make sure the directory exists
  ttestdir="$pathAnaly/ttest/$cond"
  [ ! -d $ttestdir ] && mkdir -p $ttestdir

  #run test
  3dttest++ -overwrite -mask $mask \
            -setA $(cat $pathAnaly/Control.1D ) \
            -setB $(cat $pathAnaly/Clinical.1D) \
            -prefix $ttestdir/$(date +%F)_${cond}
done

## put all tests into one giant file
3dbucket -prefix $pathAnaly/ttest/$(date +%F)_WM $pathAnaly/ttest/*/$(date +%F)_*.BRIK

