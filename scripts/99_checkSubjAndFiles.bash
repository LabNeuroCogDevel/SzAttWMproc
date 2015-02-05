#!/usr/bin/env bash

#
# this script checks for missing things
#  - get subject list from google sheet
#     - compare to whats in subjs/
#     -- possible naming convention issue preventing copy from meson->wallace->skynet
#  - sucessful behavioral processing
#  - sucessful mprage processing
#  - sucessful functional processing
#  - sucessful GLM

scriptdir="$( cd $(dirname $0); pwd)"
maindir="$(cd "$scriptdir/.."; pwd)"
cd $scriptdir;


# read in the google file
#WF20150205: sed 1d $scriptdir/SubjInfoGoogleSheet.txt | \
#         -- need to also not print lines that do not have MRID
perl -F"\t" -slane 'next if !$F[2]||$.==1;print' $scriptdir/SubjInfoGoogleSheet.txt |
 while read \
   MEGDATE MEGID MRDATE MRID Task_Order_CB \
   WM_Response_CB Attention_Subtask_Order \
   LunaCB Cohort  Counts; do

   [ -z "$MRID" ] && continue # dont bother if there is no MRID

   # test that subjects with MRIDs are accounted for
   subjdir="$maindir/subj/$MRID"
   [ ! -d $subjdir ] && 
       echo "do not have subj $MRID ($subjdir)" &&
       continue

   # test mprage exists for MRID
   t1dir=$(ls -d1 $subjdir/tfl-multiecho*|sed 1q)
   [ -z "$t1dir" -o ! -d "$t1dir" ] && 
      echo "$MRID: no mprage! ($t1dir)" && 
      continue

   # and that it has been preprocessed
   [ ! -r "$t1dir/mprage_nonlinear_warp_MNI_2mm.nii.gz" ] && 
       echo "$MRID: mprage not preprocessed!" &&
       continue

   for task in attention working; do
     for tblock in 1 2; do

       # data?
       regex=".*ep2d_MB_${task}.*_X?${tblock}_.*"
       nMBfiles=$(echo $(find -E $subjdir/MB -type f -iregex "$regex" 2>/dev/null|wc -l))
       [ -z "$nMBfiles" -o "$nMBfiles" -ne "4" ] &&
           echo "$MRID $task $tblock: bad MultiBand data (have $nMBfiles files)! ($subjdir/MB/$regex)" &&
           continue

       # preproc?
       tb_pp="$subjdir/preproc/${task}*_$tblock/nfswdktm_mean_func_5.nii.gz"
       [ ! -r $tb_pp ] && 
           echo "$MRID $task $tblock: not preprocessed! ($tb_pp)" && 
           continue
     done
   done
   
done  > missingData.log

# check if missing stuff is new
# if it is, print changes and update
git diff --exit-code missingData.log ||
       (git diff missingData.log; git add missingData.log && git commit -m 'record changes to missing data' )
