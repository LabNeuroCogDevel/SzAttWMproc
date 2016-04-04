#!/usr/bin/env bash

hrffile="HRF2_Popout+tlrc"
starttr=0
endtr=20
group=0

[ -n "$1" ] && hrffile=$1
[ -n "$2" ] && starttr=$2
[ -n "$3" ] && endtr=$3
[ -n "$4" ] && group=$4

echo "Subj Time Group InputFile"

if [ $group -eq 0 -o $group -eq 2 ]; then
    while read filename; do

	subj=$(echo $filename | cut -d "/" -f6)

	[ ! -r /Volumes/Phillips/P5/subj/$subj/contrasts/Att/${hrffile}.HEAD ] && continue

	for i in `seq $starttr $endtr`; do
		echo "${subj} tr_${i} 2 /Volumes/Phillips/P5/subj/$subj/contrasts/Att/${hrffile}[$i]"
	done

    done < "../group_analyses/Att/Control.1D"
fi


if [ $group -eq 0 -o $group -eq 1 ]; then
    while read filename; do

        #/Volumes/Phillips/P5/subj/11360_20150129/contrasts/Att/cattend_probe_2r_stats+tlrc.HEAD

        subj=$(echo $filename | cut -d "/" -f6)

	fname=/Volumes/Phillips/P5/subj/$subj/contrasts/Att/${hrffile}.HEAD
	[ ! -r $fname ] && echo "missing $subj: $fname" >&2 && continue

	for i in `seq $starttr $endtr`; do
                echo "${subj} tr_${i} 1 /Volumes/Phillips/P5/subj/$subj/contrasts/Att/${hrffile}[$i]"
        done

    done < "../group_analyses/Att/Clinical.1D"
fi
