#!/usr/bin/env bash
#set -xe

# This script runs the GLM for WM. Arguments:
#  1) subject folder (full directory)
#  2) pattern (default: "workingmemory_[12]")
# * expect there to be a subfolder in each subject's folder called MB
# * expect mprage to be tfl-multiecho-epinav-711-RMS_256x192.8/

#Orient ourselves in terms of directories
scriptdir=/Volumes/Phillips/P5/scripts
subjsdir=/Volumes/Phillips/P5/subj  

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
oneddir=$sdir/1d/WM/correct_load_wrongtogether_dlymod
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
dmodel="dmBLOCK(1)"    # cue is a variable length block covering cue, ISI & mem; variable length, but fixed amplitude
#ldmodel="BLOCK(3,1)"    # long  delay is 3s
#sdmodel="BLOCK(1,1)"    # short delay is 1s
pmodel="BLOCK(1,1)"     # average response time is 1s


#need to sort the ones that were incorrect
timing_tool.py -timing $oneddir/Wrong.1D -sort -write_timing $oneddir/Wrong_sort.1D

prefix=WM_correct_load_wrongtogether_dlymod

pattern=working*[12]
[ -n "$2" ] && pattern=$2

3dDeconvolve \
    -input $sdir/preproc/$pattern/nfswudktm_working*_5.nii.gz \
    -allzero_OK \
    -jobs 15 \
    -censor censor_total.1D \
    -num_stimts  7 \
        -stim_times_AM1 1 $oneddir/cue_ld1_Correct.1D "$dmodel" -stim_label 1 cue_ld1 \
        -stim_times_AM1 2 $oneddir/cue_ld3_Correct.1D "$dmodel" -stim_label 2 cue_ld3 \
        -stim_times_AM1 3 $oneddir/delay_ld1_Correct.1D "$dmodel" -stim_label 3 delay_ld1 \
        -stim_times_AM1 4 $oneddir/delay_ld3_Correct.1D "$dmodel" -stim_label 4 delay_ld3 \
        -stim_times 5 $oneddir/probe_ld1_Correct.1D "$pmodel" -stim_label 5 probe_ld1 \
        -stim_times 6 $oneddir/probe_ld3_Correct.1D "$pmodel" -stim_label 6 probe_ld3 \
	-stim_times 7 $oneddir/Wrong_sort.1D "$pmodel" -stim_label 7 wrong \
        -overwrite \
        -x1D Xmat_${prefix}.x1D -xjpeg dm_$prefix.png \
	-tout -fitts fitts_${prefix} -errts errts_${prefix} -bucket stats_${prefix}


#Copy template ICBM152 (1x1x1) for underlay
ln -s /Volumes/Phillips/P5/group_analyses/WM/masks_and_templates/template.nii template.nii

  #-gltsym 'SYM:.5*cue_ld3 -.5*cue_ld1' -glt_label 1 cue3vs1 \
	#-gltsym 'SYM:.5*delay_ld3 -.5*delay_ld1' -glt_label 1 delay3vs1 \
	#-gltsym 'SYM:.5*probe_ld3 -.5*probe_ld1' -glt_label 1 probe3vs1 \


