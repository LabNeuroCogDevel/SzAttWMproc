#!/usr/bin/env bash

cd /Volumes/Phillips/P5/scripts/rois

whereami -prefix BA40_L -mask_atlas_region 'TT_Daemon:316'
whereami -prefix BA40_R -mask_atlas_region 'TT_Daemon:116'
whereami -prefix BA46_L -mask_atlas_region 'TT_Daemon:322'
whereami -prefix BA46_R -mask_atlas_region 'TT_Daemon:122'
whereami -prefix BA09_L -mask_atlas_region 'TT_Daemon:289'
whereami -prefix BA09_R -mask_atlas_region 'TT_Daemon:9'
whereami -prefix BA17_L -mask_atlas_region 'TT_Daemon:294'
whereami -prefix BA17_R -mask_atlas_region 'TT_Daemon:94'

rois="BA40_L BA40_R BA46_L BA46_R BA09_L BA09_R BA17_L BA17_R"

for r in $rois; do
	 3dwarp -tta2mni -prefix ${r}_w ${r}+tlrc
	 3dresample -master /Volumes/Phillips/P5/group_analyses/Att/ttest_2015-05-01/att_flx_cor+tlrc -prefix ${r}_wr -input ${r}_w+tlrc
	 done
	 
