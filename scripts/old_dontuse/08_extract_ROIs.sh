#!/bin/bash

data=/Volumes/Phillips/P5/subj
roidir=/Volumes/Phillips/P5/scripts/rois

prefix="simpledContrasts_2runs_stats2"

rois="


#go to where all the data is
cd $data

#subjects IDs

ID="11228_20150309 11327_20140911 11333_20141017 11339_20141104 11340_20141031 11341_20141118 11348_20141119 11349_20141124 11351_20141202 11352_20141230 11354_20141205 11355_20141230 11356_20150105 11357_20150122 11358_20150129 11359_20150203 11360_20150129 11363_20150310 11365_20150407 11367_20150430 11368_20150505"

for d in ${ID}; do

    cd ${data}/${d}
    3dROIstats -quiet -mask ${roidir}/BA09_L_wr+tlrc  ${data}/${d}/contrasts/Att/${prefix}[]>>${data}/BA09_L_.txt
