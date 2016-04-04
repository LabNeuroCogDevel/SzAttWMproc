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
#
#
# run e.g. `03_GLM.bash show` to see what it will run without actually running



set -e

# go to main directory
cd $(dirname $0)/..;

for visitdir in subj/*; do
	for proto in attention workingmemory; do 

		### define subject+protocol naming

		subj=$( basename $visitdir )
		
		# shortprot: 1dfolder and contranst foler
		# glmprefix: where would completed runs be
		# cmd: what command do we use for preprocessing
		if [[ "$proto" == "attention"     ]]; then 
			shortprot="Att"
			glmprefix="simpledContrasts_2runs_stats2+tlrc.HEAD"
			cmd="scripts/deconvolve_only2Att.bash";

		#elif [[ "$proto" == "workingmemory" ]]; then
		      # 	shortprot="WM"
		#	glmprefix="${subj}_WM_DefaultContrasts_stats+tlrc.HEAD"
		#	cmd="scripts/deconvolve_only2WM.bash"

		else
			shortprot="BADPROTO"
			glmprefix="BADPROTO"
			cmd="echo \"BAD proto in code $0\" '"
		fi


		### Checks

		# skip if we've seen this before
		[ -r $visitdir/contrasts/$shortprot/${glmprefix} ] && \
			echo "* SKIP: already have constrasts ($glmprefix) for $subj $proto" && \
			continue

		# skip if we're told to
		skipmefile="$visitdir/contrasts/$shortprot/skipme"
		[ -r "$skipmefile" ] && \
			echo "* SKIP: told to skip $subj ($skipmefile)" && \
			continue
		#echo "* OKAY: did not find: $visitdir/contrasts/$shortprot/${glmprefix}"

		# check that we have 1d files (behavioral data)
		dfolderpath="$visitdir/1d/$shortprot";
		if [ ! -d  "$dfolderpath" ] && [[ "$(ls $dfolderpath/*1D 2>/dev/null|wc -l)" -le "2" ]]; then
			echo "* ERROR: DO NOT HAVE 1D files! $dfolderpath/*1D is empty"
			echo "    if this is expected: date > $skipmefile"
			continue
		fi

		# check we have nifti files (preprocessed MR data)
		pattern=${proto}_[12]
		if [ "$(ls $visitdir/preproc/$pattern/n*${pattern}_5.nii.gz 2>/dev/null| wc -l)" -lt "2" ] ; then
			echo "* ERROR: $visitdir/preproc/$pattern/n*${pattern}_5.nii.gz has too few files"
			echo "    if this is expected: date > $skipmefile"
			continue
		fi


		# if we gave any input, just show what we would od
		if [[ -n "$1" ]]; then
		  echo "##  $cmd $subj $pattern"
		# otherwise do it
		else
		  $cmd $subj $pattern
		fi

	done
done
