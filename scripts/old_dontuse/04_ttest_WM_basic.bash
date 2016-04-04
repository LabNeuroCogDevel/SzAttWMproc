#!/usr/bin/env bash

#


set -e
trap '[ "$?" -ne 0 ] && echo "$0 ended with error!"' EXIT 

# which conditions do we want to compare between controls and patients
conditions=(cue_ld1 cue_ld3 delay_ld1 delay_ld3 probe_ld1 probe_ld3 cue delay probe)

con_num=(1 4 7 10 13 16 22 25 29)

# we are using the 2.3mm brain in our final fun->mni warp
mask=$HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_mask_2.3mm.nii

# go one directory above this script to get to the main directory
maindir=$(cd $(dirname $0)/..;pwd)




# we want to organize the data, output should go here
pathAnaly="$maindir/group_analyses/WM"





# for each condition we are interseted in
for i in $(seq 0 ${#conditions[@]}); do
	     cond=${conditions[$i]}
	     con=${con_num[$i]}
	     [ -z "$cond" ] && continue
	     echo "$i $cond $con"
             

  # define where to save the ttest output
  # make sure the directory exists
  ttestdir="$pathAnaly/ttest_basic_WM_$(date +%F)"
  [ ! -d $ttestdir ] && mkdir -p $ttestdir

  #run test
  
 3dttest++ -overwrite -mask $mask \
            -setA $(sed "s/\$/[$con]/" $pathAnaly/Control.1D ) \
	    -labelA Controls \
            -setB patients $(sed "s/\$/[$con]/" $pathAnaly/Clinical.1D) \
	    -labelB Patients \
            -prefix $ttestdir/${cond}
done
## put all tests into one giant file
#3dbucket -prefix $pathAnaly/ttest/$(date +%F)_Att $pathAnaly/ttest/*/$(date +%F_*.BRIK

