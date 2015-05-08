#!/usr/bin/env bash

# USAGE:
# ./02_preproc.bash      # run everyone who's incomplete
# ./02_preproc.bash show # show don't do
# REDO=1 02_preproc.bash # redo everyone (useful if preprocessOne.bash changes)

# preprocess Multiband functionals
#
# 
# * will silently skip if expected final output nfswdktm_${protocol}_5.nii.gz exists already
# * will warn and retry if preproc dir exists but does not have final output
#
# N.B. this is 02 not because any 01 is prereq 
#      but because both this and cpMprage will run preprocessMprage
#      -- could be race condition where file is being written twice
#      so always cpMprage and then preprocess functionals


# stop runnign script if any errors
set -e

#what does the final output look like
finalpfix="nfswdktm"

CFGFILE="$(dirname $0)/jobs_cfg.bash"
# pull in waitForJobs function
#  function takes a config file as settings argument
source $CFGFILE


# we need matlab for preprocessFunctional's wavelet despiking
if ! which matlab >/dev/null; then echo "matlab needs to be in the path!" && exit 1; fi

# work from main directory
cd $(dirname $0)/..

# find all multiband images for attention and workingmemory 
#  preprocess all of those that need it
find subj/*/MB/ -type f -iname '*img' -and -not -iname '*ref.img'  \
	          -and \( -iname '*attention*' -or -iname '*working_Memory*' -or -iname '*workingMemory*' \) |
while read MBimg; do
	# get subject_visit 
	subj=$(basename $(dirname $(dirname $MBimg)))

	# get the file base, protocol, and number
	fbase=$(echo $MBimg | perl -ne 'print $1 if /((attention|working_?memory)_X?\d+)/i') 
	proto=$(echo $MBimg | perl -ne 'print lc($1) if /(attention|working_?memory)_X?(\d+)/i') 
	num=$(echo   $MBimg | perl -ne 'print $2 if /(attention|working_?memory)_X?(\d+)/i') 

	# remove underscores (working_memory to workingmemory)
	proto=${proto//_}

	[ -z "$fbase" -o -z "$proto" -o -z "$num" ] && \
		echo "$MBimg does not fit expected pattern, skipping!" && \
		continue

	savedir=${proto}_$num

	# skip if we already have preproccesed directory
	# and we dont want to redo
	[ -z "$REDO" && -r subj/$subj/preproc/$savedir/$finalpfix_${savedir}_5.nii.gz ] && continue

	skipmefile="subj/$subj/preproc/$savedir/skipme"
	[ -r "$skipmefile" ] && echo "skiping $subj $savedir ($skipmefile)" && continue
	# if we have the directory but not the final file, something went wrong before
	[ -z "$REDO" && -d subj/$subj/preproc/$savedir ] && \
	       	echo "* WARNING: $subj $savedir folder exists but not final preproc, trying to redo now!" && \
		echo "           'date > $skipmefile'  to skip"


	# if we provided an argument to the script, just show what needs to be done
	if [ -n "$1" ]; then
		echo REDO=\"$REDO\" scripts/preprocessOne.bash $subj $fbase $savedir 
		continue
	fi

	echo "$subj $fbase -> $savedir"
        REDO="$REDO" scripts/preprocessOne.bash $subj $fbase $savedir &
	# wait if we have too many jobs going
	waitForJobs $CFGFILE
done

# wait for all the jobs to finish
wait
