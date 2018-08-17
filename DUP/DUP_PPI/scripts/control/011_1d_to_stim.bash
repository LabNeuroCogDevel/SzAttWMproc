#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

#
# convert AFNI 1d files to fsl stim files
#
for ld8 in $(cat txt/complete_controls.txt); do
   [ -d PPI/$ld8/1d/sepload_probeRT ] && echo "have PPI/$ld8/1d/sepload_probeRT" && continue
   echo /Volumes/Phillips/P5/subj/$ld8/1d/WM/sepload_probeRT to PPI/$ld8/1d/
   [ ! -d PPI/$ld8/1d ] && mkdir -p PPI/$ld8/1d
   cp -r /Volumes/Phillips/P5/subj/$ld8/1d/WM/sepload_probeRT PPI/$ld8/1d/
done

# convert all 1d files to stim files
./afni_1d_to_fsl_stim.R
