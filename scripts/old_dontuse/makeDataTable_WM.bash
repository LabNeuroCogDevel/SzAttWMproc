#!/usr/bin/env bash

hrffile="cue_ld1+tlrc"
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

	[ ! -r /Volumes/Phillips/P5/subj/$subj/contrasts/WM/${hrffile}.HEAD ] && continue

	for i in `seq $starttr $endtr`; do
		echo "${subj} tr_${i} 2 /Volumes/Phillips/P5/subj/$subj/contrasts/WM/${hrffile}[$i]"
	done

    done < "../group_analyses/WM/Control.1D"
fi


if [ $group -eq 0 -o $group -eq 1 ]; then
    while read filename; do


        subj=$(echo $filename | cut -d "/" -f6)

	fname=/Volumes/Phillips/P5/subj/$subj/contrasts/WM/${hrffile}.HEAD
	[ ! -r $fname ] && echo "missing $subj: $fname" >&2 && continue

	for i in `seq $starttr $endtr`; do
                echo "${subj} tr_${i} 1 /Volumes/Phillips/P5/subj/$subj/contrasts/WM/${hrffile}[$i]"
        done

    done < "../group_analyses/WM/Clinical.1D"
fi
