#!/usr/bin/env bash

# run  GLMs when we have 2 runs of something and no glm yet
#
#    check for
#       - havent done this before
#       - 1d behav files
#       - 2 MR preprocessed 
#       
#
# N.B. if prefix names change in deconvole_only2*
#      then change glmprefix here


set -e

cd $(dirname $0);

for visitdir in subj/*; do
	for proto in attention workingmemory; do 

		### define subject+protocol naming

		subj=$( basename $visitdir )
		
		# 1dfolder and contranst foler
		shortprot="BADPROTO"
		[[ "$proto" == "attention"     ]] && shortprot="Att"
		[[ "$proto" == "workingmemory" ]] && shortprot="WM"

		# where would completed runs be
		#subj/11327_20140911/contrasts/*/*HEAD
		glmprefix="BADPROTO"
		[[ "$proto" == "attention"     ]] && glmprefix="simpledContrasts_2runs_stats+tlrc.HEAD"
		[[ "$proto" == "workingmemory" ]] && glmprefix="${subj}_WM_DefaultContrasts_stats+tlrc.HEAD"

		# what command do we use for preprocessing
		cmd="echo \"BAD proto in code $0\" '"
		[[ "$proto" == "workingmemory" ]] && cmd="./deconvolve_only2WM.bash"
		[[ "$proto" == "attention"     ]] && cmd="./deconvolve_only2Att.bash"


		### Checks

		# skip if we've seen this before
		[ -r $visitdir/contrasts/$shortprot/${glmprefix} ] && \
			echo "* SKIP: already have constrasts ($glmprefix) for $subj $proto" && \
			continue

		#echo "* OKAY: did not find: $visitdir/contrasts/$shortprot/${glmprefix}"

		# check that we have 1d files (behavioral data)
		dfolderpath="$visitdir/1d/$shortprot";
		if [ ! -d  "$dfolderpath" ] && [[ "$(ls $dfolderpath/*1D 2>/dev/null|wc -l)" -le "2" ]]; then
			echo "* ERROR: DO NOT HAVE 1D files! $dfolderpath/*1D is empty"
			continue
		fi

		# check we have nifti files (preprocessed MR data)
		pattern=${proto}_[12]
		if [ "$(ls $visitdir/preproc/$pattern/n*${pattern}_5.nii.gz 2>/dev/null| wc -l)" -lt "2" ] ; then
			echo "* ERROR: $visitdir/preproc/$pattern/n*${pattern}_5.nii.gz has too few files"
			continue
		fi




		echo $cmd $subj $pattern

	done
done
