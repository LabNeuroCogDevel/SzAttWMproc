#!/usr/bin/env bash

#Batch to run 3dMEMA for WM "bycorrect" deconvolve
#Save files to /Volumes/Phillips/P5/group_analyses/WM/ttest_bycorrect

set -xe
trap '["$?" -ne 0 ] && echo "$0 ended with error!"' EXIT

#Identify the conditions of interest to compare Control (C) vs. Patient (P)
conditions=(cue cue_load delay delay_ld delay_dly delay_ldXdly probe probe_ld probe_chg probe_ldXchg)
conB_list=(82 86 90 94 98 102 106 110 114 118)

#Specify mask as 2.3mm ICBM152 in AFNI (brik/head) format
mask=$HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_mask_2.3mm.nii

#Specify pathway for finding .1D files with lists of subject filenames to use in contrasts
pathAnaly=/Volumes/Phillips/P5/group_analyses/WM

#----------------Run Analysis---------------------------#

#Define where to save the output
  outputdir="$pathAnaly/ttest_bycorrect_mrg_$(date +%F)"
  [ ! -d $outputdir ] && mkdir -p $outputdir

#For each condition we are interseted in...
for i in $(seq 0 ${#conditions[@]}); do
             cond=${conditions[$i]}
             conB=${conB_list[$i]}
	     [ -z "$cond" ] && continue
             echo "$i $cond $conB"

#Run 3dttest++:
3dttest++ -prefix $outputdir/${cond} \
-mask $mask \
-setA CONTROLS \
c11228 /Volumes/Phillips/P5/subj/11228_20150309/contrasts/WM/bycorrect_mrg/stats_11228_20150309_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
c11339 /Volumes/Phillips/P5/subj/11339_20141104/contrasts/WM/bycorrect_mrg/stats_11339_20141104_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
c11341 /Volumes/Phillips/P5/subj/11341_20141118/contrasts/WM/bycorrect_mrg/stats_11341_20141118_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
c11349 /Volumes/Phillips/P5/subj/11349_20141124/contrasts/WM/bycorrect_mrg/stats_11349_20141124_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
c11352 /Volumes/Phillips/P5/subj/11352_20141230/contrasts/WM/bycorrect_mrg/stats_11352_20141230_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
c11356 /Volumes/Phillips/P5/subj/11356_20150105/contrasts/WM/bycorrect_mrg/stats_11356_20150105_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
c11359 /Volumes/Phillips/P5/subj/11359_20150203/contrasts/WM/bycorrect_mrg/stats_11359_20150203_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
c11360 /Volumes/Phillips/P5/subj/11360_20150129/contrasts/WM/bycorrect_mrg/stats_11360_20150129_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
c11365 /Volumes/Phillips/P5/subj/11365_20150407/contrasts/WM/bycorrect_mrg/stats_11365_20150407_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
c11374 /Volumes/Phillips/P5/subj/11374_20150529/contrasts/WM/bycorrect_mrg/stats_11374_20150529_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
-setB PATIENTS \
p11340 /Volumes/Phillips/P5/subj/11340_20141031/contrasts/WM/bycorrect_mrg/stats_11340_20141031_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11348 /Volumes/Phillips/P5/subj/11348_20141119/contrasts/WM/bycorrect_mrg/stats_11348_20141119_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11351 /Volumes/Phillips/P5/subj/11351_20141202/contrasts/WM/bycorrect_mrg/stats_11351_20141202_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11354 /Volumes/Phillips/P5/subj/11354_20141205/contrasts/WM/bycorrect_mrg/stats_11354_20141205_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11355 /Volumes/Phillips/P5/subj/11355_20141230/contrasts/WM/bycorrect_mrg/stats_11355_20141230_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11357 /Volumes/Phillips/P5/subj/11357_20150122/contrasts/WM/bycorrect_mrg/stats_11357_20150122_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11358 /Volumes/Phillips/P5/subj/11358_20150129/contrasts/WM/bycorrect_mrg/stats_11358_20150129_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11363 /Volumes/Phillips/P5/subj/11363_20150310/contrasts/WM/bycorrect_mrg/stats_11363_20150310_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11368 /Volumes/Phillips/P5/subj/11368_20150505/contrasts/WM/bycorrect_mrg/stats_11368_20150505_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11369 /Volumes/Phillips/P5/subj/11369_20150519/contrasts/WM/bycorrect_mrg/stats_11369_20150519_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11386 /Volumes/Phillips/P5/subj/11386_20150619/contrasts/WM/bycorrect_mrg/stats_11386_20150619_WM_bycorrect_mrg+tlrc.BRIK[$conB] \
p11407 /Volumes/Phillips/P5/subj/11407_20150716/contrasts/WM/bycorrect_mrg/stats_11407_20150716_WM_bycorrect_mrg+tlrc.BRIK[$conB] \

    done
done 
