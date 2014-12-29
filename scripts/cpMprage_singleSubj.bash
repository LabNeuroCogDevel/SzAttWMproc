#!/usr/bin/env bash

#
# take a luna id and upload to server (will's computer) where MEG have access
#
#  - use preprocessMprage if cannot find mprage.nii.gz
#  - use google doc to match MEG ID to MR ID
#  - write avalToMEG as audit in mprage dir
#  - rsync

scriptdir=$(cd $(dirname $0); pwd)
subjsdir="$scriptdir/.."
# google doc location
#url=https://docs.google.com/spreadsheets/d/1tklWovQor7Nt3m0oWsiP2RPRwDauIS8QUtY4la2kHac
googleSheet="$scriptdir/SubjInfoGoogleSheet.txt"
host=open@reese # edit ~/.ssh/config and ssh-copy-id for automation 
remotepath='~/P5'
flagfile=avalToMeg


id=$1
[ -z "$id" ]  && echo "need id as first argument" && exit 1

file="$(find $subjsdir/$id/tfl-multiecho-epinav-* -name mprage.nii.gz|tail -n1)"
if [ -z "$file" ]; then
  t1dir="$(find $subjsdir/$id/ -name 'tfl-multiecho-epinav-*'|tail -n1)"
  [ -z "$t1dir" ] && echo "cannot find a t1 dir for $id" && exit 1

  cd $t1dir
  preprocessMprage -d archive -r MNI_2mm -p "MR*"
  file="$(find $subjsdir/$id/tfl-multiecho-epinav-* -name mprage.nii.gz|tail -n1)"
fi

# check again for file, something went wrong with preprocessMPRAGE
[ -z "$file" ]  && echo "preprocessMprage broken? couldn't find mprage.nii.gz for $id after running" && exit 1


#MEGID=$(curl -s "$url/export?format=tsv"| awk "(\$4==\"$id\"){print \$2}")
MEGID=$(awk "(\$4==\"$id\"){print \$2}" "$googleSheet" )
[ -z "$MEGID" ]  && echo "cannot find $id in sheet\n see $googleSheet (pulled from google in 00_fetchData.bash)" && exit 1

uploadpath=$host:$remotepath/MEG${MEGID}_MR${id}_mprage.nii.gz
rsync -vhi $file $uploadpath

# write a file to says we transfered this mprage
# this will be useful for any automated scripts (they'll know to skip running this)
echo  "$uploadpath $(date +%F)" > $(dirname $file)/$flagfile
