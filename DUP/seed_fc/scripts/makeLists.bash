#!/usr/bin/env bash

###
# makeLists.bash 
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


cd $(dirname $0)


# a list of subjects
DUPLIST=DUP.lst 

# a list of masks
MASKLIST=masks.lst

fileList=""

  for ROI in $(cat $MASKLIST); do
    
    thisFile=/Volumes/Phillips/P5/DUP/seed_fc/subjs/1*_2*/1*_${ROI}_corrmap_z.nii.gz
    
    fileList="$fileList /n $thisFile"

    echo $fileList

        # /Volumes/Phillips/P5/DUP/seed_fc/subjs/1*_2*/1*_${ROI}_corrmap_z.nii.gz
            # OR  (worse :) )
                #  allfiles=""; for f in /Volumes/Phillips/P5/DUP/seed_fc/subjs/1*_2*/1*_${ROI}_corrmap_z.nii.gz; do allfiles="$allfiles $f"; done
#                   allargs=""
                        # 11340_20141031    1.301029996000000
#                           cat $DUPLIST| while read subj dup;do
#                                  f=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/1*_${ROI}_corrmap_z.nii.gz
#                                         allargs="$allargs $dup $f";


    
    done



 echo "done."
