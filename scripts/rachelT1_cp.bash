#!/usr/bin/env bash

err() {
 echo $@ >&2
 exit 1
}

cd $(dirname $0)

[ -z "$1" ] && err "USAGE: $0 MEGID (e.g 2177)"
ismount=$(mount | grep biomarkers) 
[ ! -d /Volumes/biomarkers -o -z "$ismount" ] && err "need  mount_smbfs //foranw@oacres1.acct.upmchs.net/rcn2/biomarkers /Volumes/biomarkers 
"

t1root=/Volumes/Phillips/P5/subj
lookuptxt=$(cd $(dirname $0);pwd)/SubjInfoGoogleSheet.txt

[ ! -d "$t1root" ] && err "NO T1 root dir $t1root!!!!" 
[ ! -r "$lookuptxt" ] && err "$lookuptxt DNE, cannot look up meg->lunaid" 

megid=$1; 
# check megid
[ -z "$megid" ] && err "need a meg id"
[[ ! "$megid" =~ ^[0-9]{4}$ ]] && err "expect meg id to be 4 digitis" 

cpdir=/Volumes/biomarkers/$megid
lunaid=$(awk "( \$2 == $megid){print \$4}" $lookuptxt); 
# check
[[ -z "$lunaid"  || ! "$lunaid" =~ [0-9]{5}_[0-9]{8} ]] && err "$megid did not match any lunaid in $lookuptxt" 

t1d=$(find $t1root/$lunaid/ -maxdepth 1 -type d -iname 'tfl-multiecho*'|tail -n1); 

[ -z "$t1d" -o ! -d "$t1d" ] && err "$megid as $lunaid has no t1dir in $t1root"

rsync --size-only -Lvhir $t1d/ $cpdir --exclude '[^M]*' --exclude '*.nii.gz' --exclude '*/.*'

echo "$0 finished copy of $megid ($t1d to $cpdir)" | mail -s "[automatic update] $megid T1" foranw@upmc.edu kaskiere@upmc.edu

#if [ -n "$t1d" -a ! -d "$cpdir" ]; then
# cp -r $t1d $cpdir
#else
# echo "already have $t1d as $cpdir"
#fi

