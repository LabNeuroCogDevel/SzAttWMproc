#!/usr/bin/env bash

# Need behave for 1d files
#  -- if we find a subj_visit directory without a 1d directory
#     run getBehave_single.bash


set -e

# go to script directory
cd $(dirname $0)

googleSheet="SubjInfoGoogleSheet.txt"
[ ! -r $googleSheet ] && echo "cannot find/open $googleSheet!" && exit 1
# look inside each subject directory
#  try to find a 1d folder.
#  if it's not there, run getBehave_single.bash to create it
#  visitdir is your luna lab id + scan date
for visitdir in ../subj/*/; do

   #if a 1d file exists for each subject continue on
   # maybe we are missing other things though
   missing=""
   for finalfile in  csv/{WorkingMemory,Attention}_$(basename $visitdir)_behave.csv ; do
     [ ! -r $finalfile ] && missing="$missing $finalfile" 
   done
   if [ -d $visitdir/1d ]; then
     [ -n "$missing" ] && echo "skip b/c have ${visitdir}1d but still missing$missing!" >&2
     continue
   fi

   #set id 
   id=$(basename $visitdir)
   [[ ! "$id" =~ [0-9]{5}_[0-9]{8} ]] && echo "id ($id) is not expected from '$visitdir'!!" && continue
   #go to field 4 of the google sheet and make sure that equals id
   #then print out the cohort (field 9)
   #cohort=$(awk "(\$4==\"$id\"){print \$9}" "$googleSheet") # 20150106WF - awk skips fields if only whitespace
   cohort=$(perl -F"\t" -slane "print \$F[8] if(\$F[3]==\"$id\")" "$googleSheet" )
   [[ ! $cohort =~ Control|Clinical ]] && echo "$id cohort '$cohort' is not Control or Clinical! skipping" && continue
   #use those variables to run that command
   ! ./getBehave_single.bash $id $cohort && continue;

   #20150520 MJ - add attention_redo for Att bycorrect_mrg & correct_trialOnly
   ./Att/redo_attention1D.bash $id;
done
