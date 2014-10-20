#!/usr/bin/env bash

# give me a luna_date (or any path that ends in a luna_id)
# and i'll give you 1d files into subj/luna_date/1d/

# matlab write 1D scripts are from task github repo
# get 1D 
#   svn export https://github.com/LabNeuroCogDevel/CircleSacTasks/trunk/private/write1DAtt.m     
#   svn export https://github.com/LabNeuroCogDevel/CircleSacTasks/trunk/private/write1DWM.m 
# get behave
#   svn export https://github.com/LabNeuroCogDevel/CircleSacTasks/trunk/attBehav.m
#   svn export https://github.com/LabNeuroCogDevel/CircleSacTasks/trunk/WMBehav.m
#   svn export https://github.com/LabNeuroCogDevel/CircleSacTasks/trunk/writeBehavCSV.m


# need luna_date to do anything
ld=$1
[[ -z "$ld" ]] && echo "first argument should be a luna_date" && exit 1

ld=$(basename $ld) # so we can use subj/11327_20140911/ (tab complete for lazy)
[[ ! "$ld" =~ [0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]  ]] && \
	 echo "first argument should be a luna_date" && exit

# TODO: instead of requiring, we can just search the two
cohort=$2
[[ -z "$cohort" || ! "$cohort" =~ Basic|Clinical  ]] && \
	 echo "second argument should be either Basic or Clinical" && exit

# need bea_res to get behave data
mntcmd="/sbin/mount -t smbfs '//foranw:Wh!sl00king@oacres1/rcn1/' ~/rcn"
bea_res="/Users/lncd/rcn/bea_res"
[ ! -d $bea_res ] && eval "$mntcmd"


# run everything relative to script directory
cd $(dirname $0)

# need to have a subject directory locally
[ ! -r subj/$ld ] && echo "no subject dir $(pwd)/subj/$ld" && exit 1
# and on B
luna=${ld%%_*}
visit=${ld##*_}

## Attention
set -x
echo "WM $bea_res/Data/Tasks/P5SzWM/$cohort/$luna/$visit/mat/ subj/$ld/1d/WM write1DWM
Att "$bea_res/Data/Tasks/Attention/$cohort/$luna/$visit/mat/" "subj/$ld/1d/Att" write1DAtt" |\
 while read task getDir savDir onedfunc; do
   ## WM
   #task="WM"
   #getDir="$bea_res/Data/Tasks/SzWM/$cohort/$luna/$visit/mat/"
   #savDir="subj/$ld/1d/WM"
   #onedfunc="write1DWM"
   [[ -z "$getDir" || ! -d $getDir ]] && echo "no $task task dir @ $getDir" && continue 
   # copy attention mat to dir
   [ ! -d $savDir ] && mkdir -p $savDir
   cp $getDir/*mat $savDir/
   mat="$(find $savDir -name '*mat'|sed 1q)"
   # run matlab
   matlab -nodesktop -r "try,$onedfunc('$mat','$savDir'),end; quit"
done
##ATT
#attGetDir="$bea_res/Data/Tasks/Attention/$cohort/$luna/$visit/mat/"
#attSavDir="subj/$ld/1d/Att"
#[ ! -d $attGetDir ] && echo "no att task dir @ $attGetDir" && exit 1
## copy attention mat to dir
#[ ! -d $attSavDir ] && mkdir -p $attSavDir
#cp $attGetDir/*mat $attSavDir/
#mat="$(find $attSavDir -name '*mat'|sed 1q)"
## run matlab
#matlab -nodesktop -r "try,write1DAtt('$mat','$attSavDir'),end; quit"



