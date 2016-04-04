#!/usr/bin/env bash

SCRIPTDIR=$(dirname $0)
SUBJDIR=$(cd $(dirname $0)/../subj;pwd)

subj1dDir=$(pwd)/../group_analyses/Att/HRF/subj1d
maskdir=$(pwd)/../group_analyses/Att/HRF

forceWrite=0

[ ! -r $subj1dDir ] && mkdir -p $subj1dDir

[ $forceWrite -eq 1 ] && rm $subj1dDir/*1d

while read maskname maskfile mrangelow mrangehigh; do

	[ -z $maskname ] && continue

	for hrfref in $SUBJDIR/*/contrasts/Att/HRF2_Popout+tlrc.HEAD; do
		cdir=$(dirname $hrfref)
		echo $hrfref
		subj=$(echo $hrfref | cut -d "/" -f6)
		echo $subj

		for hrffile in $cdir/HRF2_*HEAD; do
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
pop1 clust_popout+tlrc 1 1
pop2 clust_popout+tlrc 2 2
pop3 clust_popout+tlrc 3 3
pop4 clust_popout+tlrc 4 4
pop5 clust_popout+tlrc 5 5
pop6 clust_popout+tlrc 6 6
pop7 clust_popout+tlrc 7 7
pop8 clust_popout+tlrc 8 8
hab1 clust_habitual+tlrc 1 1
hab2 clust_habitual+tlrc 2 2
hab3 clust_habitual+tlrc 3 3
hab4 clust_habitual+tlrc 4 4
flex1 clust_flexible+tlrc 1 1
EOF



patfile=$subj1dDir/../../patients.1D
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
