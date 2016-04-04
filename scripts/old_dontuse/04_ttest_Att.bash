#!/usr/bin/env bash

#
# currently for attention only
#   * simpledContrasts_2runs_stats+tlrc.HEAD
#     - att_GLT
#
#  save files for each group in ../group_analyses/Att/*.1D
#                 each ttest in ../group_analyses/Att/ttest/$condition/$condition_$date
#
#


set -e
trap '[ "$?" -ne 0 ] && echo "$0 ended with error!"' EXIT 

# which conditions do we want to compare between controls and patients
conditions=(cue_pop_cor att_pop_cor prb_pop_cor cue_hab_cor att_hab_cor prb_att_cor cue_flx_cor att_flx_cor prb_flx_cor cue_GLT att_GLT prb_GLT att_habVpop_GLT att_flxVpop_GLT att_flxVhab_GLT cue_habVpop_GLT cue_flxVpop_GLT cue_flxVhab_GLT prb_habVpop_GLT prb_flxVpop_GLT prb_flxVhab_GLT)

con_num=(1 4 7 10 13 16 19 22 25 31 34 37 40 43 46 49 52 55 58 61 64)

# we are using the 2.3mm brain in our final fun->mni warp
mask=$HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_mask_2.3mm.nii

# go one directory above this script to get to the main directory
maindir=$(cd $(dirname $0)/..;pwd)

# google doc that has updated information
#MEGDATE MEGID MRDATE MRID Task_Order_CB WM_Response_CB Attention_Subtask_Order LunaCB Cohort  Counts    
#column 4 is MRID
#       9 is cohort
subjtxt="$maindir/scripts/SubjInfoGoogleSheet.txt"




# we want to organize the data, output should go here
pathAnaly="$maindir/group_analyses/Att"
#[ ! -d $pathAnaly ] && mkdir -p $pathAnaly

### build cohorts


# clear all cohort files
# WF20150225 - google sheet updated, cohorts are in field 10 instead of 9
cut -f10 -d "	" $subjtxt|sed 1d | sort | uniq | while read cohort; do echo -n "" > $pathAnaly/$cohort.1D; done

# (re)build the cohort files
#  - `sed` to remove header from the google doc
#  - `cut` to get MRID (luna_date, column/field 4) and cohort (field 9) 
#  - `echo >>` to write/append each contrast in the approprate cohort text file
#MJ20150225 - google sheet updated $MRID in field 5 instead of 4
sed 1d "$subjtxt" | cut -f5,10 -d"	" | while read MRID cohort; do
 contrastfile="$maindir/subj/$MRID/contrasts/Att/contrasts_modelinc_2runs_stats+tlrc.HEAD"

 [ ! -r "$contrastfile" ] && 
     echo "SKIPPING $MRID ($cohort): no contrasts file ($contrastfile)" && 
     continue

 echo $contrastfile >> $pathAnaly/$cohort.1D
done




# for each condition we are interseted in
for i in $(seq 0 ${#conditions[@]}); do
	     cond=${conditions[$i]}
	     con=${con_num[$i]}
	     [ -z "$cond" ] && continue
	     echo "$i $cond $con"
             

  # define where to save the ttest output
  # make sure the directory exists
  ttestdir="$pathAnaly/ttest_modelinc_$(date +%F)"
  [ ! -d $ttestdir ] && mkdir -p $ttestdir

  #run test
  
 3dttest++ -overwrite -mask $mask \
            -setA $(sed "s/\$/[$con]/" $pathAnaly/Control.1D ) \
	    -labelA C \
            -setB $(sed "s/\$/[$con]/" $pathAnaly/Clinical.1D) \
	    -labelB P \
            -prefix $ttestdir/${cond}
done


## put all tests into one giant file
#3dbucket -prefix $pathAnaly/ttest/$(date +%F)_Att $pathAnaly/ttest/*/$(date +%F_*.BRIK

