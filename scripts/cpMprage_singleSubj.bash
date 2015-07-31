#!/usr/bin/env bash

#
# take a luna id and upload to server (will's computer) where MEG have access
#
#  - use preprocessMprage if cannot find mprage.nii.gz
#  - use google doc to match MEG ID to MR ID
#  - write avalToMEG as audit in mprage dir
#  - rsync

scriptdir=$(cd $(dirname $0); pwd)
subjsdir=$(cd $scriptdir/../subj;pwd)

# get MEGID from google sheet given a lunaid
source $scriptdir/MEGID.src.bash

host=open@reese # edit ~/.ssh/config and ssh-copy-id for automation 
remotepath='~/P5'
flagfile=avalToMeg


id=$1
[ -z "$id" ]  && echo "need id as first argument" && exit 1

function findmprage() {
 find $subjsdir/$id/tfl-multiecho-epinav-* -name mprage.nii.gz|tail -n1
}

file="$(findmprage)"

if [ -z "$file" ]; then
  t1dir="$(find $subjsdir/$id/ -type d -name 'tfl-multiecho-epinav-*'|tail -n1)"
  [ -z "$t1dir" ] && echo "cannot find a t1 dir for $id" && exit 1

  cd $t1dir
  preprocessMprage -d archive -r MNI_2mm -p "MR*" &
  sleep 120 # enough time for Dimon to complete

  # maybe we didn't way long enough
  if [ -z "$(findmprage)" ]; then
     wait 
     file="$(findmprage)"
  fi
fi

# check again for file, something went wrong with preprocessMPRAGE
[ -z "$file" ]  && echo "preprocessMprage broken? couldn't find mprage.nii.gz for $id after running" && exit 1


MEGID="$(getMEGID $id )"
uploadpath=$host:$remotepath/MEG${MEGID}_MR${id}_mprage.nii.gz
rsync -vhi $file $uploadpath

# write a file to says we transfered this mprage
# this will be useful for any automated scripts (they'll know to skip running this)
echo  "$uploadpath $(date +%F)" > $(dirname $file)/$flagfile

# wait for preprocessMprage to finish before trying anything else
wait
