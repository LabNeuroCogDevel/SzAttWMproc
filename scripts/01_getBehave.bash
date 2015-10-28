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
    [ -d $visitdir/1d ] && continue
   #set id 
    id=$(basename $visitdir)
    #go to field 4 of the google sheet and make sure that equals id
    #then print out the cohort (field 9)
   #cohort=$(awk "(\$4==\"$id\"){print \$9}" "$googleSheet") # 20150106WF - awk skips fields if only whitespace
   cohort=$(perl -F"\t" -slane "print \$F[8] if(\$F[3]==\"$id\")" "$googleSheet" )
#use those variables to run that command
   ./getBehave_single.bash $id $cohort;
#20150520 MJ - add attention_redo for Att bycorrect_mrg & correct_trialOnly
   ./redo_attention1D.bash $id;
done
