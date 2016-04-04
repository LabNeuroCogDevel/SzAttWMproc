#!/usr/bin/env bash

starttr=0
endtr=16
group=0

[ -n "$2" ] && starttr=$1
[ -n "$3" ] && endtr=$2

echo "Subj Time Group Load Delay InputFile"

files=(cue_ld1_dly1 cue_ld3_dly1 cue_ld1_dly3 cue_ld3_dly3)
loads=(1 3 1 3)
delays=(1 1 3 3)
    
while read filename; do

	subj=$(echo $filename | cut -d "/" -f6)

	[ $(ls /Volumes/Phillips/P5/subj/$subj/contrasts/WM/cue_ld*_dly*.HEAD|wc -l) -ne 4 ] && continue

	for c in `seq 0 3`; do
		file=${files[c]}+tlrc
		load=${loads[c]}
		delay=${delays[c]}

		for i in `seq $starttr $endtr`; do
			echo "${subj} tr_${i} 1 ${load} ${delay} /Volumes/Phillips/P5/subj/$subj/contrasts/WM/${file}[$i]"
		done

	done    
done < "../group_analyses/WM/Control.1D"


while read filename; do

        subj=$(echo $filename | cut -d "/" -f6)

        [ $(ls /Volumes/Phillips/P5/subj/$subj/contrasts/WM/cue_ld*_dly*.HEAD|wc -l) -ne 4 ] && continue

        for c in `seq 0 3`; do
                file=${files[c]}+tlrc
                load=${loads[c]}
                delay=${delays[c]}

                for i in `seq $starttr $endtr`; do
                        echo "${subj} tr_${i} 2 ${load} ${delay} /Volumes/Phillips/P5/subj/$subj/contrasts/WM/${file}[$i]"
                done

	done
done < "../group_analyses/WM/Clinical.1D"
