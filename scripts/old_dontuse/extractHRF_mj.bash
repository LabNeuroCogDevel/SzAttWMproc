#!/usr/bin/env bash

SCRIPTDIR=/Volumes/Phillips/P5/scripts
SUBJDIR=/Volumes/Phillips/P5/subj

subj1dDir=/Volumes/Phillips/P5/group_analyses/WM/HRF_2015-12-17/subj1d
maskdir=/Volumes/Phillips/P5/group_analyses/Att/HRF_2015-12-17

forceWrite=0

[ ! -r $subj1dDir ] && mkdir -p $subj1dDir

[ $forceWrite -eq 1 ] && rm $subj1dDir/*1d

while read maskname maskfile mrangelow mrangehigh; do

	[ -z $maskname ] && continue

	for hrfref in $SUBJDIR/*/contrasts/WM/delay3_ld3+tlrc.HEAD; do
		cdir=$(dirname $hrfref)
		echo $hrfref
		subj=$(echo $hrfref | cut -d "/" -f6)
		echo $subj

		for hrffile in /Volumes/Phillips/P5/group_anlayses/WM/HRF_2015-12-17/delay3_ld3+tlrc.HEAD; do
			file=$(basename $hrffile)
			outfile=${file/+tlrc.HEAD}
			outfile="$subj-$maskname-$outfile.1d"
			
			[ -r $subj1dDir/$outfile -a $forceWrite -eq 0 ] && continue

			echo "$maskname $subj $(basename $hrffile)"
			3dmaskave -quiet -mask "${maskdir}/${maskfile}" -mrange $mrangelow $mrangehigh  $hrffile  > $subj1dDir/$outfile
#			3dmaskSVD -mask ${maskdir}/${maskfile}"<${mrangelow}..${mrangehigh}>" -input $hrffile > $subj1dDir/$outfile

		done

	done

   let ++ct || echo count err

done <<EOF
d3ld3_1 clust_popout+tlrc 1 1
d3dl3_2 clust_popout+tlrc 2 2
d3ld3_3 clust_popout+tlrc 3 3
d3ld3_4 clust_popout+tlrc 4 4
d3ld3_5 clust_popout+tlrc 5 5
#pop6 clust_popout+tlrc 6 6
#pop7 clust_popout+tlrc 7 7
#pop8 clust_popout+tlrc 8 8
#hab1 clust_habitual+tlrc 1 1
#hab2 clust_habitual+tlrc 2 2
#hab3 clust_habitual+tlrc 3 3
#hab4 clust_habitual+tlrc 4 4
3flex1 clust_flexible+tlrc 1 1
EOF



patfile=/Volumes/Phillips/P5/group_analyses/WM/Clinical.1D
outfile=$subj1dDir/../allTRs.txt
echo "" > $outfile
for file in $subj1dDir/*; do

	infostring=$(basename $file)
	infostring=${infostring//-/ }
	infostring=${infostring/.1d}

	parts=($infostring)
	subj=${parts[0]}

	n=$(grep -c $subj $patfile)
	group=1
	if [ $n -eq 0 ]; then
		group=2
	fi

#	echo $subj $group
	tr=0
	while read val; do
		echo "$infostring $group $tr $val" >> $outfile
		let ++tr || 0
	done < "$file"

done
