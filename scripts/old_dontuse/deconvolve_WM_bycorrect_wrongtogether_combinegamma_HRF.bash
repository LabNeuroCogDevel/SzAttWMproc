#!/usr/bin/env bash
#set -xe

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

#Make sure we have 1d files - pulling from separate stim files 

oneddir1=$sdir/1d/WM/correct_load_wrongtogether_dlymod
[ ! -d "$oneddir1" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir1

oneddir2=$sdir/1d/WM/correct_load_wrongtogether_sepdly

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

#Specify GAMMA cue and probe, incorrect
dmodel="dmBLOCK(1)"   

#specify TENT for delay period
tmodel="TENT(0,20,21)"



prefix=WM_correct_load_wrongtogether_combo_gamma_HRF

pattern=working*[12]
[ -n "$2" ] && pattern=$2

3dDeconvolve \
    -input $sdir/preproc/$pattern/nfswudktm_working*_5.nii.gz \
    -allzero_OK \
    -jobs 15 \
    -censor censor_total.1D \
    -num_stimts  11 \
        -stim_times_AM1 1 $oneddir1/cue_ld1_Correct.1D "$dmodel" -stim_label 1 cue_ld1 \
        -stim_times_AM1 2 $oneddir1/cue_ld3_Correct.1D "$dmodel" -stim_label 2 cue_ld3 \
        -stim_times 3 $oneddir2/delay_ld1_dly1_Correct.1D "$tmodel" -stim_label 3 delay_ld1_dly1 \
	-stim_times 4 $oneddir2/delay_ld1_dly3_Correct.1D "$tmodel" -stim_label 4 delay_ld1_dly3 \
	-stim_times 5 $oneddir2/delay_ld3_dly1_Correct.1D "$tmodel" -stim_label 5 delay_ld3_dly1 \
	-stim_times 6 $oneddir2/delay_ld3_dly3_Correct.1D "$tmodel" -stim_label 6 delay_ld3_dly3 \
        -stim_times_AM1 7 $oneddir1/probe_ld1_Correct.1D "$dmodel" -stim_label 7 probe_ld1 \
        -stim_times_AM1 8 $oneddir1/probe_ld3_Correct.1D "$dmodel" -stim_label 8 probe_ld3 \
	-stim_times_AM1 9 $oneddir1/cueonly_incorrect.1D "$dmodel" -stim_label 9 cue_inc \
	-stim_times_AM1 10 $oneddir1/dlyonly_incorrect.1D "$dmodel" -stim_label 10 dly_inc \
	-stim_times_AM1 11 $oneddir1/probe_incorrect.1D "$dmodel" -stim_label 11 prb_inc \
	-iresp 3 "delay_ld1_dly_combo" \
	-iresp 4 "delay_ld1_dl_combo" \
	-iresp 5 "delay1_ld3_dl1_combo" \
	-iresp 6 "delay3_ld3_dly3_combo" \
        -overwrite \
        -x1D Xmat_${prefix}.x1D -xjpeg dm_$prefix.png \
	-tout -fitts fitts_${prefix} -errts errts_${prefix} -bucket stats_${prefix}


#Copy template ICBM152 (1x1x1) for underlay
ln -s /Volumes/Phillips/P5/group_analyses/WM/masks_and_templates/template.nii template.nii

  #-gltsym 'SYM:.5*cue_ld3 -.5*cue_ld1' -glt_label 1 cue3vs1 \
	#-gltsym 'SYM:.5*delay_ld3 -.5*delay_ld1' -glt_label 1 delay3vs1 \
	#-gltsym 'SYM:.5*probe_ld3 -.5*probe_ld1' -glt_label 1 probe3vs1 \


