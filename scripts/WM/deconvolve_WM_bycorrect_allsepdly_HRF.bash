#!/usr/bin/env bash
set -xe

# This script runs the GLM for WM. Arguments:
#  1) subject folder (full directory)
#  2) pattern (default: "workingmemory_[12]")
# * expect there to be a subfolder in each subject's folder called MB
# * expect mprage to be tfl-multiecho-epinav-711-RMS_256x192.8/

#Orient ourselves in terms of directories
scriptdir=$(cd $(dirname $0);pwd)
subjsdir=$scriptdir/../subj  

#Find subject
s=$1
[ -z "$s" ] && echo "need a subject directory as first argument!" && exit 1

#Look in different places for the subject
[ ! -d "$s" ] && s=$scriptdir/$1
[ ! -d "$s" ] && s=$scriptdir/../$1
[ ! -d "$s" ] && s=$subjsdir/$1
[ ! -d "$s" ] && echo "cannot find subj dir ($1 or $s)" && exit 1

#Go into the directory we found and make sure we have absolute path
#Reset s to be the subject again
cd $s
sdir=$(pwd);
s=$(basename $sdir)

#Make sure we have 1d files 
oneddir=$sdir/1d/WM/R1D_nomarry
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

#Setup directory for contrasts 
contrasts=$sdir/contrasts/WM
[ ! -d "$contrasts" ] && mkdir -p $contrasts


#Create censor_total.1D file by catenating the censor_union.1D files in the "motion_info" subfolders of each run
cd $contrasts
cat $sdir/preproc/workingmemory_1/motion_info/censor_union.1D $sdir/preproc/workingmemory_2/motion_info/censor_union.1D > censor_total.1D

#------------------------------------------------------#
#-------------------Run 3dDeconvolve-------------------#
#------------------------------------------------------#

cd $contrasts

#Specify models for stimulus funcions
#0=start time
#20=end time
#21= # of TRs
model="TENT(0,20,21)"

prefix=WM_correct_cue_load_catch_wrong_allsepdly

pattern=working*[12]
[ -n "$2" ] && pattern=$2

3dDeconvolve \
    -input $sdir/preproc/$pattern/nfswudktm_working*_5.nii.gz \
    -mask /Users/lncd/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c_2.3mm.nii \
    -allzero_OK \
    -jobs 8 \
    -polort 3 \
    -censor censor_total.1D \
    -local_times \
    -num_stimts  9 \
        -stim_times 1 $oneddir/cue_correct_ld1_delay1.1D "$model" -stim_label 1 cue_ld1_dly1 \
        -stim_times 2 $oneddir/cue_correct_ld1_delay3.1D "$model" -stim_label 2 cue_ld1_dly3 \
	-stim_times 3 $oneddir/cue_correct_ld3_delay1.1D "$model" -stim_label 3 cue_ld3_dly1 \
	-stim_times 4 $oneddir/cue_correct_ld3_delay3.1D "$model" -stim_label 4 cue_ld3_dly3 \
	-stim_times 5 $oneddir/cue_catchDelay.1D "$model" -stim_label 5 catch_delay \
        -stim_times 6 $oneddir/cue_catchProbe_delay1.1D "$model" -stim_label 6 catch_probe_dly1 \
        -stim_times 7 $oneddir/cue_catchProbe_delay3.1D "$model" -stim_label 7 catch_probe_dly3 \
        -stim_times 8 $oneddir/cue_incorrect_delay1.1D "$model" -stim_label 8 wrong_dly1 \
	-stim_times 9 $oneddir/cue_incorrect_delay3.1D "$model" -stim_label 9 wrong_dly3 \
	-iresp 1 "cue_ld1_dly1" \
	-iresp 2 "cue_ld1_dly3" \
	-iresp 3 "cue_ld3_dly1" \
	-iresp 4 "cue_ld3_dly3" \
	-iresp 5 "catch_delay" \
	-iresp 6 "catch_probe_dly1" \
	-iresp 7 "catch_probe_dly3" \
	-iresp 8 "wrong_dly1" \
	-iresp 9 "wrong_dly3" \
        -overwrite \
        -x1D Xmat_${prefix}_HRF.x1D -xjpeg dm_$prefix.png \
	#-tout -fitts fitts_${prefix} -errts errts_${prefix} -bucket stats_${prefix} don't need for tent function
	#-stim_times 9 $oneddir/Wrong.1D "$model" -stim_label 9 wrong 
	#-iresp 9 "wrong" \


#Copy template ICBM152 (1x1x1) for underlay
ln -s /Volumes/Phillips/P5/group_analyses/WM/masks_and_templates/template.nii template.nii


