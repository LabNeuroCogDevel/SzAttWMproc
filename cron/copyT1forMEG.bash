#!/usr/bin/env bash


#
# search for tfl-multiecho folders
# look inside those for "$flagfile" (say if it's already been transfered)
# if not there, transfer using cpMprage.sh
#
# NOTE: could remove flagfile, transfer is done with rsync

# if we find more than one, we want the last one
# so we'll end up trasnfering the first, than the second
# but keeping the second

subjdir=/Volumes/Phillips/SzAttWM/subj
flagfile=avalToMeg

find $subjdir -type d -maxdepth 2 -mindepth 2 -name 'tfl-multiecho-*'  |
 while read t1dir; do
  MRid=$(basename $(dirname $t1dir))
  
  # skip MRid's that don't look like luna ids: 00000_00000000
  [[ ! "$MRid" =~ [0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]] && continue
  [ ! -r $t1dir/$flagfile ]  && ../cpMprage.sh $MRid
done
