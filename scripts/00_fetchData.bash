#!/usr/bin/env bash

# make sure we are running from within the scripts directory
cd $(dirname $0)
subjroot=$(pwd)/../subj
[ ! -d $subjroot ] && echo "cannot find subject root dir $subjroot!" && exit 1
# get rid of ..
subjroot=$(cd $subjroot;pwd)

# write skip message
function skip {
 [ -n "$DEBUG" ] && echo -e $@
 return 0
}
# send warning
function warn {
 DEBUG=1 skip "WARNING: $@"
}
# find mr in specified folder
function findmr {
  find "$1" -maxdepth 1 -type f -iname 'MR*'            
}

# look for subject dates to skip
function isskipsubj {
 s="$1"

 # subject matches
 [ $s == "11423_20150902" ] && return 0   # 2 parter, default to: 11423_20150916

 # append other subjects to skip here
 #[ $s == "99999_yyyymmdd" ] && return 0  # skip because: 

 # otherwise dont skip
 return 1
}


# link over over MB
# multiband folder has funny name
# 1. try to pull out lunaid_date 
# 2. link to subj/$lunaid_$date/MB/
for mb in /Volumes/Phillips/Raw/MRprojects/P5Sz/multiband/*; do
   s=$(basename $mb)
   [[ ! $s =~ ([0-9]{5})_([0-9]{8}) ]] && warn "$s does not contain luna_date ($mb)" && continue

   # skip some subjects, see func def above
   isskipsubj $s && continue

   l=${BASH_REMATCH[1]}; d=${BASH_REMATCH[2]}; 
   MB="$subjroot/${l}_$d/MB/"
   # need to make directory if it doesn't exit
   [ ! -d $MB ] && mkdir -p $MB
   continue
   # always skip this, ?? why
   find $mb -maxdepth 1 -type f | while read mbf; do
    lnto=$MB/$(basename $mbf)
    [ ! -e $lnto ] &&  ln -s $mbf $lnto
   done

done


# look through each raw date/subject/protocol and link to subj/protocol/MR*
# check that links don't already exist before linking
for sd in /Volumes/Phillips/Raw/MRprojects/P5Sz/[^m]*/*; do
   s=$(basename $sd)
   [[ ! $s =~ ^([0-9]{5})_([0-9]{8})$ ]] && warn "$s is not like luna_date ($sd)" && continue

   # skip some subjects, see func def above
   isskipsubj $s && continue

   l=${BASH_REMATCH[1]}; d=${BASH_REMATCH[2]}; 
   for f in $sd/*{tfl,diff,gre_field}*/;do
      [ ! -r $f ] && skip "cannot find $f in $sd" && continue
      sfdir="$subjroot/$s/$(basename $f)/"

      find $sfdir -iname '*nii.gz' >/dev/null 2>&1 && skip "found niis, skipping\n\t try: ln -s $f/* $sfdir" && continue

      [ $(findmr $f     2>/dev/null|wc -l) -eq \
        $(findmr $sfdir 2>/dev/null|wc -l) ] && continue

      [ ! -d "$sfdir" ] && mkdir -p $sfdir
      findmr $f | while read mr; do
         lnto=$sfdir/$(basename $mr)
         [ ! -r $mr ] && warn "somethings really weird! cannot read dicom $mr, not linking to $lnto!\n\t abandoning linking all of $f" && break
         [ ! -e $lnto ] && ln -s $mr $lnto
      done

   done
done


# copy google sheet with IDs and info in it
url=https://docs.google.com/spreadsheets/d/1tklWovQor7Nt3m0oWsiP2RPRwDauIS8QUtY4la2kHac
#curl is a command to transfer a url
#copy the google sheet into a text file
curl -s "$url/export?format=tsv" > SubjInfoGoogleSheet.txt




# rsync is a file transfer program capable of efficient remote update via a fast differencing algorithm
#-v=verbose
#-r=recursive into directory
#-z=compress file data during transfer
#-h=output numbers in a human readable format
#Will is getting the data from Wallace and copying it to Phillips
#size-only: it checks to see if the sizes on wallace match the file sizes on Skynet, if they don't match it does copy over

# -- wallace is out of space, raw moved to skynet
#rsync -rvzhi foranw@wallace:/data/Luna1/Raw/P5Sz/ ../subj/ --size-only

#rsync -rvzhi /Volumes/Phillips/Raw/MRprojects/P5Sz/*/ ../subj/ --size-only --dry-run

