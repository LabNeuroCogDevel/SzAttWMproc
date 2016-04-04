#!/usr/bin/env bash

# generated cputime.txt # $0 | tee cputime.txt
# use log file to get how long each step takes
# BUG: doesn't do well if process went across 2 days

set -e
function exiterr {
  echo "$@"
  exit 1
}
function secfromLog {
   log=$1
   part=$2
   [ -z "$log" -o ! -r $log ] && exiterr "no log: $log"
   [ -z "$part" ] && exiterr "need search part"

   ptime=$(perl -lne "print if s/.*$part ([\-0-9]{10})\+(.*)/\1 \2/i" $log)
   secs=$(date -j -f "%Y-%m-%d %H:%M" "$ptime" +%s )
   [ -z "$secs" ] && echo "no secs for $log $part!" >&2 && return 1
   echo $secs
}

function gettime {
   nii=$1
   log=$2
   [ -z "$nii" -o ! -r "$nii" ] && exiterr "no nii: $nii"
   [ -z "$log" -o ! -r "$log" ] && exiterr "no log: $log"

   starttime_sec=$(secfromLog $log started)

   if [[ $nii =~ nii ]]; then
     end_sec=$(stat -f %m $nii);
   else
     end_sec=$(secfromLog $log finished)
   fi
   #echo "times: $starttime_sec to $end_sec" >&2

   [ -z "$end_sec" -o -z "$starttime_sec" ] && echo "missing start ($starttime_sec) or end ($end_sec)" >&2

   #(grep started $log;stat $nii) |sed 's/^/\t/g' >&2
   echo "scale=3; ( $end_sec - $starttime_sec)/60^2" | bc
}

for mpragedir in ../subj/*/tfl-multiecho-*/; do
   subj=$(basename $(dirname $mpragedir) )
   nii="$mpragedir/mprage_bet_fast_wmseg.nii.gz"
   log="$mpragedir/preprocessMprage.log"
   [ ! -r $log ] && log="$mpragedir/../preprocessMprage.log"
   [ ! -r $log ] && continue
   hours=$(gettime $nii $log)
   echo "$subj mprage $hours"
done
# preprocessFunctional v11/17/2014 
# Run started 2015-03-10+11:02  
# finished 2015-03-10+11:58

for pplog in ../subj/*/preproc/*/.preprocessfunctional_complete ; do
   taskpath=$(dirname $pplog)
   subj=$(basename $(dirname $taskpath) )
   hours=$(gettime $pplog $pplog)
   echo "$subj $(basename $taskpath) $hours"
done
