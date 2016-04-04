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
oneddir=$sdir/1d/WM/R1D_SPMG3_nomarry
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

#Specify models for stimulus funcions-SPMG3

spmod1="SPMG3(1)" #dly1 is 1s and average RT is 1s
spmod2="SPMG3(3)" #dly3 is 3s
spmod3="SPMG3(0.8)" #average cue length is .8s


prefix=WM_correct_load_sepwrong_sepdly_SPMG3

pattern=working*[12]
[ -n "$2" ] && pattern=$2

3dDeconvolve \
    -input $sdir/preproc/$pattern/nfswudktm_working*_5.nii.gz \
    -allzero_OK \
    -jobs 8 \
    -censor censor_total.1D \
    -local_times \
    -GOFORIT 4 \
    -num_stimts  12 \
        -stim_times 1 $oneddir/cue_ld1_incCatch_Correct.1D "$spmod3" -stim_label 1 cue_ld1_spmg3 \
        -stim_times 2 $oneddir/cue_ld3_incCatch_Correct.1D "$spmod3" -stim_label 2 cue_ld3_spmg3 \
        -stim_times 3 $oneddir/delay_ld1_dly1_incCatch_Correct.1D "$spmod1" -stim_label 3 delay1_ld1_spmg3 \
        -stim_times 4 $oneddir/delay_ld1_dly3_incCatch_Correct.1D "$spmod2" -stim_label 4 delay3_ld1_spmg3 \
	-stim_times 5 $oneddir/delay_ld3_dly1_incCatch_Correct.1D "$spmod1" -stim_label 5 delay1_ld3_spmg3 \
        -stim_times 6 $oneddir/delay_ld3_dly3_incCatch_Correct.1D "$spmod2" -stim_label 6 delay3_ld3_spmg3 \
        -stim_times 7 $oneddir/probe_ld1_Correct.1D "$spmod1" -stim_label 7 probe_ld1_spmg3 \
        -stim_times 8 $oneddir/probe_ld3_Correct.1D "$spmod1" -stim_label 8 probe_ld3_spmg3 \
	-stim_times 9 $oneddir/cue_wrong.1D "$spmod3" -stim_label 9 cue_wrong_spmg3 \
	-stim_times 10 $oneddir/probe_wrong.1D "$spmod1" -stim_label 10 probe_wrong_spmg3 \
	-stim_times 11 $oneddir/delay_dly1_wrong.1D "$spmod1" -stim_label 11 delay_dly1_wrong_spmg3 \
	-stim_times 12 $oneddir/delay_dly3_wrong.1D "$spmod2" -stim_label 12 delay_dly3_wrong_spmg3 \
	-iresp 1 "cue_ld1_spmg3" \
	-iresp 2 "cue_ld3_spmg3" \
	-iresp 3 "delay1_ld1_spmg3" \
	-iresp 4 "delay3_ld1_spmg3" \
	-iresp 5 "delay1_ld3_spmg3" \
	-iresp 6 "delay3_ld3_spmg3" \
	-iresp 7 "probe_ld1_spmg3" \
	-iresp 8 "porbe_ld3_spmg3" \
	-iresp 9 "cue_wrong_spmg3" \
	-iresp 10 "probe_wrong_spmg3" \
	-iresp 11 "delay_dly1_wrong_spmg3" \
	-iresp 12 "delay_dly3_wrong_spmg3" \
        -overwrite \
        -x1D Xmat_${prefix}.x1D -xjpeg dm_$prefix.png \
	-tout -fitts fitts_${prefix} -errts errts_${prefix} -bucket stats_${prefix}


#Copy template ICBM152 (1x1x1) for underlay
#ln -s /Volumes/Phillips/P5/group_analyses/WM/masks_and_templates/template.nii template.nii

  #-gltsym 'SYM:.5*cue_ld3 -.5*cue_ld1' -glt_label 1 cue3vs1 \
	#-gltsym 'SYM:.5*delay_ld3 -.5*delay_ld1' -glt_label 1 delay3vs1 \
	#-gltsym 'SYM:.5*probe_ld3 -.5*probe_ld1' -glt_label 1 probe3vs1 \


