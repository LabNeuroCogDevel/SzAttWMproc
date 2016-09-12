#!/usr/bin/env bash

# for s in ../subj/1*/; do ./cpDTI_singleSubj.bash $s; done  # skips if already done (have flagfile)

#
# take a luna id and upload  DTI to server (will's computer) where MEG group have access
#
#  - use google doc to match MEG ID to MR ID
#  - write dtiAvalToMEG as audit in DTI dir
#  - rsync

scriptdir=$(cd $(dirname $0); pwd)
subjsdir=$(cd $scriptdir/../subj;pwd)

# get MEGID from google sheet given a lunaid
source $scriptdir/MEGID.src.bash
source $scriptdir/dtidcm2nii.bash

host=open@reese # edit ~/.ssh/config and ssh-copy-id for automation 
remotepath='~/P5'
flagfilename=dtiAvalToMeg


id=$1
[ -z "$id" ]  && echo "need id as first argument" && exit 1

flagfile=$(id2dir $id)/dti/$flagfilename
[ -r $flagfile ] && warn "$id already has dti copied: $(cat $flagfile)" && exit 0

dtidir=$(dtidcm2nii $id) || exit 1


MEGID="$(getMEGID $id )" || exit 1
uploadpath=$host:$remotepath/DTI/MEG$MEGID
set -x
rsync -rvhi $(dirname $flagfile) $uploadpath

# write a file to says we transfered this mprage
# this will be useful for any automated scripts (they'll know to skip running this)
echo  "$uploadpath $(date +%F)" > $flagfile

