#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
cd $(dirname $0) # run from the script directory

#
# run feat on all wm1 and wm2 runs (L1)
#
# like:
#  ./L1_feat.bash delay_L1_template_sepload.fsf LDC ../../../../subj/11608_20170425/preproc/workingmemory_1/nfswudktm_working_memory_1_5.nii.gz
MAXJOBS=10
SLEEPTIME=60
waitforjobs(){
   i=1
   while [ $(jobs -p|wc -l) -ge $MAXJOBS ]; do
      echo "$i $(date +%FT%H:%M) $MAXJOBS sleep $SLEEPTIME ($n)"
      sleep $SLEEPTIME
      let ++i
   done
}

n=1
for ld8 in $(cat txt/complete_controls.txt); do
   for f in ../../../../subj/$ld8/preproc/working*memory_[12]/nfswudktm_working*memory_[12]_5.nii.gz; do
       for roi in $(cat txt/rois.txt); do
          ./L1_feat.bash delay_L1_template_sepload.fsf $roi $f &
          let n++
          waitforjobs
       done
   done
done
