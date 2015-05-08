#!/usr/bin/env bash

# copy of getBehave_single.bash
#
# simlified to just redo attention where we 
# 1) "bycorrect_mrg/"
#   merge:
#   - correct and catch
#   - missed and wrong
# 2)"correct_trialOnly/"
#   pull out correct trials
#   - cue of every full correct trial into 1d for pop,hab,flex
#
# for ld in ../subj/*_*; do ./redo_attetion1D.bash $(basename $ld); done

set -e
trap '[ "$?" -ne 0 ] && echo "$0 ended with error!"' EXIT


scriptdir=$(cd $(dirname $0);pwd)
subjdir=$(cd $scriptdir/../subj;pwd)
# need luna_date to do anything
#first argument is a luna date
#a luna_date looks like this 11333_20141017
ld=$1
[[ -z "$ld" ]] && echo "first argument should be a luna_date" && exit 1

#set the luna_date as the basename for the subject directories
ld=$(basename $ld) # so we can use ../subj/11327_20140911/ (tab complete for lazy)
[[ ! "$ld" =~ [0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]  ]] && \
	 echo "first argument should be a luna_date" && exit


# run everything relative to script directory
#$0 expands to the name of the shell or shell script
#go into the directory that the shell script is contained in
#the dollar sign before it gets you the VALUE of the variable
cd $(dirname $0)

# need to have a subject directory locally (on Phillips)
[ ! -r $subjdir/$ld ] && echo "no subject dir $subjdir/$ld" && exit 1
# and on B
luna=${ld%%_*}
visit=${ld##*_}

## creat 1D files, create behave csv file
#1D files are the timing files that you are going to need later on
#prints out the variables you'll need in the "while read section"
#echo  "WM $bea_res/Data/Tasks/P5SzWM/$cohort/$luna/$visit/mat/    $subjdir/$ld/1d/WM  write1DWM  WMBehav

savDir="$subjdir/$ld/1d/Att"
mat="$(find $savDir -name '*mat'|sed 1q)"
# run matlab
#running these files: attBehav.m, WMBehav.m, writeBehaveCSV.m
mlcmd="try, write1DAtt('$mat','$savDir/bycorrect_mrg','correct','ctch=crct;slw=wrg'),end;quit;"
matlab -nodisplay -r "$mlcmd"

# 20150508 -- trial only
mlcmd="try, write1DAtt('$mat','$savDir/correct_trialOnly','trialonly'),end;quit;"
#echo "$mlcmd"
matlab -nodisplay -r "$mlcmd"



