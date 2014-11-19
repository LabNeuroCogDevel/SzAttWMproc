#!/usr/bin/env bash
set -e

# preprocess Multiband functionals
# 
# * will silently skip if expected final output nfswdktm_${protocol}_5.nii.gz exists already
# * will warn and retry if preproc dir exists but does not have final output
#
# N.B. this is 02 not because any 01 is prereq 
#      but because both this and cpMprage will run preprocessMprage
#      -- could be race condition where file is being written twice
#      so always cpMprage and then preprocess functionals

# work from script directory
cd $(dirname $0)

# find all multiband images for attention and workingmemory 
#  preprocess all of those that need it
find subj/*/MB/ -type f -iname '*img' -and -not -iname '*ref.img'  \
	          -and \( -iname '*attention*' -or -iname '*working_Memory*' -or -iname '*workingMemory*' \) |
while read MBimg; do
	# get subject_visit 
	subj=$(basename $(dirname $(dirname $MBimg)))

	# get the file base, protocol, and number
	fbase=$(echo $MBimg | perl -ne 'print $1 if /((attention|working_?memory)_X?\d+)/i') 
	proto=$(echo $MBimg | perl -ne 'print $1 if /(attention|working_?memory)_X?(\d+)/i') 
	num=$(echo   $MBimg | perl -ne 'print $2 if /(attention|working_?memory)_X?(\d+)/i') 

	# remove underscores (working_memory to workingmemory)
	proto=${proto//_}

	[ -z "$fbase" -o -z "$proto" -o -z "$num" ] && \
		echo "$MBimg does not fit expected pattern, skipping!" && \
		continue

	savedir=${proto}_$num

	# skip if we already have preproccesed directory
	[ -r subj/$subj/preproc/$savedir/nfswdktm_${savedir}_5.nii.gz ] && continue

	# if we have the directory but not the final file, something went wrong before
	[ -d subj/$subj/preproc/$savedir ] && \
	       	echo "* WARNING: $subj $savedir folder exists but not final preproc, trying to redo now!"


        echo ./preprocessOne.bash $subj $fbase $savedir
done

