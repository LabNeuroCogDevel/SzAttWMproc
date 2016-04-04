#!/usr/bin/env bash

SCRIPTDIR=/Volumes/Phillips/P5/scripts
subjdir=/Volumes/Phillips/P5/subj

subj1dDir=/Volumes/Phillips/P5/group_analyses/WM/subj1d/extractHRF_allsepdly_SVD
roidir=/Volumes/Phillips/P5/scripts/ROIs/BA_spheres

forceWrite=0

[ ! -r $subj1dDir ] && mkdir -p $subj1dDir

[ $forceWrite -eq 1 ] && rm $subj1dDir/*1d

ID="10843_20151015 11228_20150309 11333_20141017 11339_20141104 11340_20141031 11341_20141118 11348_20141119 11349_20141124 11351_20141202 11352_20141230 11354_20141205 11355_20141230 11356_20150105 11357_20150122 11358_20150129 11359_20150203 11360_20150129 11363_20150310 11365_20150407 11367_20150430 11368_20150505 11369_20150519 11374_20150529 11386_20150619 11390_20150721 11407_20150716 11418_20151201 11423_20150916 11424_20150908 11432_20150922 11433_20150924 11454_20151019 11466_20151125 11473_20151217 11476_20151219 11477_20160108 11478_20151230 11479_20160108 11483_20160128 11485_20160112 11494_20160202"

#ID="11485_20160112"

rois="LBA17 RBA17 LBA9 RBA9 LBA40 RBA40 LBA46 RBA46"

conditions="cue_ld1_dly1 cue_ld1_dly3 cue_ld3_dly1 cue_ld3_dly3 catch_probe_dly1 catch_probe_dly3 catch_delay wrong_dly1 wrong_dly3"


cd $subjdir

for roi in $rois; do
   for condition in $conditions; do
       for d in $ID;do

	   output=${subj1dDir}/${d}_${condition}_${roi}_SVD.1D 
	   #echo ${d}
	   #echo ${output}
	   3dmaskSVD -mask $roidir/${roi}_10mm+tlrc ${subjdir}/${d}/contrasts/WM/${condition}+tlrc |cat -n | sed "s/^/$d $condition $roi/" | tee ${output}
	   #3dROIstats -quiet -mask $currmask $subbrick_l | cat -n | sed "s/^/$id $bart long $i /"
	  
       done
       cat ${subj1dDir}/*_${condition}_${roi}_SVD.1D > ${subj1dDir}/${condition}_${roi}_group_SVD.1D
   done
done | tee $subj1dDir/alltentfiles.txt
