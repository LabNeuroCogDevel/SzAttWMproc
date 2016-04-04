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
conditions=(catt_pop_cor prb_pop_cor catt_hab_cor prb_hab_cor catt_flx_cor prb_flx_cor cattPopvcattHab cattPopvcattHab cueattFlxvcueattHab prbFlxvprbHab cueattFlxvcueattPop prbFlxvprbPo)

con_num=(1 4 7 10 13 16 19 22 25 28 31 34)

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







# for each condition we are interseted in
for i in $(seq 0 ${#conditions[@]}); do
	     cond=${conditions[$i]}
	     con=${con_num[$i]}
	     [ -z "$cond" ] && continue
	     echo "$i $cond $con"
             

  # define where to save the ttest output
  # make sure the directory exists
  ttestdir="$pathAnaly/ttest_cueatt_$(date +%F)"
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

