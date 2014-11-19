#!/usr/bin/env bash
set -xe

# MEG group needs the T1 images
#
# copy all the mprages that have not been copied yet
#  - we assume if the t1 dcm dir has "avalToMeg" then we do not need to send again
#  - this file is created by cpMprage_singleSubj.bash
#  - ./cpMprage_singleSubj.bash SUBJID 
#      1. runs preprocess_mprage
#      2. gets MEG ID from google docs
#      3. transfers mprage to MEG computer
#      4. write avalToMeg file
#

# go to script directory
cd $(dirname $0)

for t1dir in subj/*/tfl*; do  
	[ ! -r $t1dir/avalToMeg ] && ./cpMprage_singleSubj.bash $(basename $(dirname $t1dir));
done
