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
oneddir=$sdir/1d/WM/correct_load_wrongtogether_sepmem
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
dmodel="dmBLOCK(1)"    # cue is a variable length block covering ISI & mem; variable length, but fixed amplitude
ldmodel="BLOCK(3,1)"    # long  delay is 3s
sdmodel="BLOCK(1,1)"    # short delay is 1s
pmodel="BLOCK(2,1)"     # probe is 2s
mmodel="BLOCK(.2,1)"


prefix=WM_correct_load_wrongtogether_sepmem

pattern=working*[12]
[ -n "$2" ] && pattern=$2

3dDeconvolve \
    -input $sdir/preproc/$pattern/nfswudktm_working*_5.nii.gz \
    -allzero_OK \
    -jobs 8 \
    -censor censor_total.1D \
    -num_stimts  9 \
        -stim_times_AM1 1 $oneddir/cue_ld1_Correct.1D "$dmodel" -stim_label 1 cue_ld1 \
        -stim_times_AM1 2 $oneddir/cue_ld3_Correct.1D "$dmodel" -stim_label 2 cue_ld3 \
	-stim_times 3 $oneddir/mem_ld1_Correct.1D "$mmodel" -stim_label 3 mem_ld1 \
        -stim_times 4 $oneddir/mem_ld3_Correct.1D "$mmodel" -stim_label 4 mem_ld3 \
        -stim_times 5 $oneddir/delay_ld1_Correct.1D "$ldmodel" -stim_label 5 delay_ld1 \
        -stim_times 6 $oneddir/delay_ld3_Correct.1D "$ldmodel" -stim_label 6 delay_ld3 \
        -stim_times 7 $oneddir/probe_ld1_Correct.1D "$pmodel" -stim_label 7 probe_ld1 \
        -stim_times 8 $oneddir/probe_ld3_Correct.1D "$pmodel" -stim_label 8 probe_ld3 \
	-stim_times 9 $oneddir/Wrong.1D "$pmodel" -stim_label 9 wrong \
	-num_glt 6 \
        -gltsym 'SYM:.5*cue_ld1 +.5*cue_ld3' -glt_label 1 cue \
        -gltsym 'SYM:.5*delay_ld1 +.5*delay_ld3' -glt_label 2 delay \
        -gltsym 'SYM:.5*probe_ld1 +.5*probe_ld3' -glt_label 3 probe \
        -overwrite \
        -x1D Xmat_${prefix}.x1D -xjpeg dm_$prefix.png \
	-tout -fitts fitts_${prefix} -errts errts_${prefix} -bucket stats_${prefix}


#Copy template ICBM152 (1x1x1) for underlay
ln -s /Volumes/Phillips/P5/group_analyses/WM/masks_and_templates/template.nii template.nii

  #-gltsym 'SYM:.5*cue_ld3 -.5*cue_ld1' -glt_label 1 cue3vs1 \
	#-gltsym 'SYM:.5*delay_ld3 -.5*delay_ld1' -glt_label 1 delay3vs1 \
	#-gltsym 'SYM:.5*probe_ld3 -.5*probe_ld1' -glt_label 1 probe3vs1 \


