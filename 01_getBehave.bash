#!/usr/bin/env bash

# Need behave for 1d files
#  -- if we find a subj_visit directory without a 1d directory
#     run getBehave_single.bash

#set -xe

# go to script directory
cd $(dirname $0)

googleSheet="SubjInfoGoogleSheet.txt"
# look inside each subject directory
#  try to find a 1d folder.
#  if it's not there, run getBehave_single.bash to create it
for visitdir in subj/*/; do  
   [ -d $visitdir/1d ] && continue
   id=$(basename $visitdir)
   cohort=$(awk "(\$4==\"$id\"){print \$9}" "$googleSheet"|sed 's/Control/Basic/' )

   echo ./getBehave_single.bash $id $cohort;
done
