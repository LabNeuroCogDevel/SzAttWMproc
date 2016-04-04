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

#Make sure we have 1d files (NB: THIS DIRECTORY CHANGES for different deconvolve scripts/analyses; make sure correct!)
oneddir=$sdir/1d/WM/bycorrect_mrg
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

#Setup directory for contrasts (NB: THIS DIRECTORY CHANGES for different deconvolve scripts: make sure correct!)
contrasts=$sdir/contrasts/WM/bycorrect_mrg
[ ! -d "$contrasts" ] && mkdir -p $contrasts

#Create motion_regressors.1D files by concatenating motion.par files from preproc folder
cd $contrasts
cat $sdir/preproc/workingmemory_1/motion.par $sdir/preproc/workingmemory_2/motion.par > motion_regressors.1D

#Create censor_total.1D file by catenating the censor_union.1D files in the "motion_info" subfolders of each run
cd $contrasts
cat $sdir/preproc/workingmemory_1/motion_info/censor_union.1D $sdir/preproc/workingmemory_2/motion_info/censor_union.1D > censor_total.1D

#------------------------------------------------------#
#-------------------Run 3dDeconvolve-------------------#
#------------------------------------------------------#

cd $contrasts

#Specify models for stimulus funcions
dmodel="dmUBLOCK(1)"    # cue is a variable length block covering ISI & mem; variable length, but fixed amplitude
ldmodel="BLOCK(3,1)"    # long  delay is 3s
sdmodel="BLOCK(1,1)"    # short delay is 1s
pmodel="BLOCK(2,1)"     # probe is 2s

prefix=${s}_WM_bycorrect_mrg

pattern=working*[12]
[ -n "$2" ] && pattern=$2

3dDeconvolve \
    -input $sdir/preproc/$pattern/nfswudktm_working*_5.nii.gz \
    -allzero_OK \
    -GOFORIT 99 \
    -singvals \
    -jobs 8 \
    -polort 3 \
    -censor censor_total.1D \
    -num_stimts 26 \
        -stim_file 1 motion_regressors.1D[0] -stim_base 1 -stim_label 1 motion1 \
        -stim_file 2 motion_regressors.1D[1] -stim_base 2 -stim_label 2 motion2 \
	-stim_file 3 motion_regressors.1D[2] -stim_base 3 -stim_label 3 motion3 \
	-stim_file 4 motion_regressors.1D[3] -stim_base 4 -stim_label 4 motion4 \
	-stim_file 5 motion_regressors.1D[4] -stim_base 5 -stim_label 5 motion5 \
	-stim_file 6 motion_regressors.1D[5] -stim_base 6 -stim_label 6 motion6 \
	-local_times \
        -stim_times_AM1 7 ../../../1d/WM/bycorrect_mrg/cue_ld1_Correct.1D "$dmodel" -stim_label 7 cue_ld1 \
        -stim_times_AM1 8 ../../../1d/WM/bycorrect_mrg/cue_ld3_Correct.1D "$dmodel" -stim_label 8 cue_ld3 \
        -stim_times 9 ../../../1d/WM/bycorrect_mrg/delay_ld1_dly0_Correct.1D "$sdmodel" -stim_label 9 delay_ld1_dly0 \
        -stim_times 10 ../../../1d/WM/bycorrect_mrg/delay_ld3_dly0_Correct.1D "$sdmodel" -stim_label 10 delay_ld3_dly0 \
        -stim_times 11 ../../../1d/WM/bycorrect_mrg/delay_ld1_dly1_Correct.1D "$ldmodel" -stim_label 11 delay_ld1_dly1 \
        -stim_times 12 ../../../1d/WM/bycorrect_mrg/delay_ld3_dly1_Correct.1D "$ldmodel" -stim_label 12 delay_ld3_dly1 \
        -stim_times 13 ../../../1d/WM/bycorrect_mrg/probe_ld1_chg0_Correct.1D "$pmodel" -stim_label 13 probe_ld1_chg0 \
        -stim_times 14 ../../../1d/WM/bycorrect_mrg/probe_ld3_chg0_Correct.1D "$pmodel" -stim_label 14 probe_ld3_chg0 \
        -stim_times 15 ../../../1d/WM/bycorrect_mrg/probe_ld1_chg1_Correct.1D "$pmodel" -stim_label 15 probe_ld1_chg1 \
        -stim_times 16 ../../../1d/WM/bycorrect_mrg/probe_ld3_chg1_Correct.1D "$pmodel" -stim_label 16 probe_ld3_chg1 \
	\
	-stim_times_AM1 17 ../../../1d/WM/bycorrect_mrg/cue_ld1_Wrong.1D "$dmodel" -stim_label 17 cue_ld1_wrong \
        -stim_times_AM1 18 ../../../1d/WM/bycorrect_mrg/cue_ld3_Wrong.1D "$dmodel" -stim_label 18 cue_ld3_wrong \
	-stim_times 19 ../../../1d/WM/bycorrect_mrg/delay_ld1_dly0_Wrong.1D "$sdmodel" -stim_label 19 delay_ld1_dly0_wrong \
	-stim_times 20 ../../../1d/WM/bycorrect_mrg/delay_ld3_dly0_Wrong.1D "$sdmodel" -stim_label 20 delay_ld3_dly0_wrong \
	-stim_times 21 ../../../1d/WM/bycorrect_mrg/delay_ld1_dly1_Wrong.1D "$ldmodel" -stim_label 21 delay_ld1_dly1_wrong \
	-stim_times 22 ../../../1d/WM/bycorrect_mrg/delay_ld3_dly1_Wrong.1D "$ldmodel" -stim_label 22 delay_ld3_dly1_wrong \
	-stim_times 23 ../../../1d/WM/bycorrect_mrg/probe_ld1_chg0_Wrong.1D "$pmodel" -stim_label 23 probe_ld1_chg0_wrong \
	-stim_times 24 ../../../1d/WM/bycorrect_mrg/probe_ld3_chg0_Wrong.1D "$pmodel" -stim_label 24 probe_ld3_chg0_wrong \
	-stim_times 25 ../../../1d/WM/bycorrect_mrg/probe_ld1_chg1_Wrong.1D "$pmodel" -stim_label 25 probe_ld1_chg1_wrong \
	-stim_times 26 ../../../1d/WM/bycorrect_mrg/probe_ld3_chg1_Wrong.1D "$pmodel" -stim_label 26 probe_ld3_chg1_wrong \
	\
        -num_glt 10 \
        -gltsym 'SYM:.5*cue_ld1 +.5*cue_ld3' -glt_label 1 cue \
        -gltsym 'SYM:.5*cue_ld3 -.5*cue_ld1' -glt_label 2 cue_load \
        \
        -gltsym 'SYM:.25*delay_ld3_dly1 +.25*delay_ld3_dly0 +.25*delay_ld1_dly1 +.25*delay_ld1_dly0' -glt_label 3 delay \
        -gltsym 'SYM:.25*delay_ld3_dly1 +.25*delay_ld3_dly0 -.25*delay_ld1_dly1 -.25*delay_ld1_dly0' -glt_label 4 delay_ld \
        -gltsym 'SYM:.25*delay_ld3_dly1 -.25*delay_ld3_dly0 +.25*delay_ld1_dly1 -.25*delay_ld1_dly0' -glt_label 5 delay_dly \
        -gltsym 'SYM:.25*delay_ld3_dly1 -.25*delay_ld3_dly0 -.25*delay_ld1_dly1 +.25*delay_ld1_dly0' -glt_label 6 delay_ldXdly \
        -gltsym 'SYM:.25*probe_ld3_chg1 +.25*probe_ld3_chg0 +.25*probe_ld1_chg1 +.25*probe_ld1_chg0' -glt_label 7 probe \
        -gltsym 'SYM:.25*probe_ld3_chg1 +.25*probe_ld3_chg0 -.25*probe_ld1_chg1 +.25*probe_ld1_chg0' -glt_label 8 probe_ld \
        -gltsym 'SYM:.25*probe_ld3_chg1 -.25*probe_ld3_chg0 +.25*probe_ld1_chg1 -.25*probe_ld1_chg0' -glt_label 9 probe_chg \
        -gltsym 'SYM:.25*probe_ld3_chg1 -.25*probe_ld3_chg0 -.25*probe_ld1_chg1 +.25*probe_ld1_chg0' -glt_label 10 probe_ldXchg \
        \
        \
        -overwrite \
        -x1D Xmat_${prefix}.x1D -x1D_uncensored uncensored_Xmat_${prefix}.x1D -xjpeg Xmat_image_$prefix.png \
	-fout -tout -rout -fitts fitts_${prefix} -errts errts_${prefix} -bucket stats_${prefix}


#Copy template ICBM152 (1x1x1) for underlay
ln -s /Volumes/Phillips/P5/group_analyses/WM/masks_and_templates/template.nii template.nii

#Run 3dREMLfit to obtain estimates for parameters after prewhitening of residuals (using a voxel-wise ARMA(1,1) model).
#reml_cmd=stats_${prefix}.REML_cmd
#reml_cmd_edited=${reml_cmd}_edited
#sed 's/-tout/-GOFORIT 99 -tout/' $reml_cmd> $reml_cmd_edited #add -GOFORIT & jobs options (used '-tout' arbitrarily, as insertion point)
#chmod 777 $reml_cmd_edited
#./$reml_cmd_edited

#Old syntax for running 3dREMLfit
#input=$sdir/preproc/$pattern/nfswudktm_working*_5.nii.gz
#3dREMLfit -matrix Xmat.x1D \
#-GOFORIT 4 \
#-input $input \
#-fout -tout -Rbuck stats_REML -Rvar stats_REMLvar \
#-Rfitts fitts_REML -Rerrts errts_REML -verb $*
