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

#Specify tent model
model= "TENT(0,18,19)"


prefix=WM_correct_load_wrongtogether_dlymod_HRF

pattern=working*[12]
[ -n "$2" ] && pattern=$2

3dDeconvolve \
    -input $sdir/preproc/$pattern/nfswudktm_working*_5.nii.gz \
    -allzero_OK \
    -jobs 15 \
    -censor censor_total.1D \
    -num_stimts  7 \
        -stim_times 1 $oneddir/cue_ld1_Correct.1D "$model" -stim_label 1 cue_ld1 \
        -stim_times 2 $oneddir/cue_ld3_Correct.1D "$model" -stim_label 2 cue_ld3 \
        -stim_times 3 $oneddir/delay_ld1_Correct.1D "$model" -stim_label 3 delay_ld1 \
        -stim_times 4 $oneddir/delay_ld3_Correct.1D "$model" -stim_label 4 delay_ld3 \
        -stim_times 5 $oneddir/probe_ld1_Correct.1D "$model" -stim_label 5 probe_ld1 \
        -stim_times 6 $oneddir/probe_ld3_Correct.1D "$model" -stim_label 6 probe_ld3 \
	-stim_times 7 $oneddir/Wrong.1D "$model" -stim_label 7 wrong \
        -iresp 1 "cue_ld1" \
        -iresp 2 "cue_ld3" \
        -iresp 3 "delay_ld1" \
        -iresp 4 "delay_ld3" \
        -iresp 5 "probe_ld1" \
        -iresp 6 "probe_ld3" \
        -iresp 7 "wrong" \
        -overwrite \
        -x1D Xmat_${prefix}.x1D -xjpeg dm_$prefix.png \
	-tout -fitts fitts_${prefix} -errts errts_${prefix} -bucket stats_${prefix}


