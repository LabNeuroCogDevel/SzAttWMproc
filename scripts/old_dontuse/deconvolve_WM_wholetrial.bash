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
oneddir=$sdir/1d/WM/wholetrial
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

#Setup directory for contrasts (NB: THIS DIRECTORY CHANGES for different deconvolve scripts: make sure correct!)
contrasts=$sdir/contrasts/WM/wholetrial
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
dmodel="dmUBLOCK(1)"    # cue is a variable length block covering whole trial (cue+isi+mem+delay+probe)
#ldmodel="BLOCK(3,1)"    # long  delay is 3s
#sdmodel="BLOCK(1,1)"    # short delay is 1s
#pmodel="BLOCK(2,1)"     # probe is 2s

prefix=${s}_WM_wholetrial

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
    -num_stimts 10 \
        -stim_file 1 motion_regressors.1D[0] -stim_base 1 -stim_label 1 motion1 \
        -stim_file 2 motion_regressors.1D[1] -stim_base 2 -stim_label 2 motion2 \
	-stim_file 3 motion_regressors.1D[2] -stim_base 3 -stim_label 3 motion3 \
	-stim_file 4 motion_regressors.1D[3] -stim_base 4 -stim_label 4 motion4 \
	-stim_file 5 motion_regressors.1D[4] -stim_base 5 -stim_label 5 motion5 \
	-stim_file 6 motion_regressors.1D[5] -stim_base 6 -stim_label 6 motion6 \
	-local_times \
        -stim_times_AM1 7 ../../../1d/WM/wholetrial/cue_ld1_Correct.1D "$dmodel" -stim_label 7 cue_ld1 \
        -stim_times_AM1 8 ../../../1d/WM/wholetrial/cue_ld3_Correct.1D "$dmodel" -stim_label 8 cue_ld3 \
	\
	-stim_times_AM1 9 ../../../1d/WM/wholetrial/cue_ld1_Wrong.1D "$dmodel" -stim_label 9 cue_ld1_wrong \
        -stim_times_AM1 10 ../../../1d/WM/wholetrial/cue_ld3_Wrong.1D "$dmodel" -stim_label 10 cue_ld3_wrong \
	\
        -num_glt 2 \
        -gltsym 'SYM:.5*cue_ld1 +.5*cue_ld3' -glt_label 1 cue \
        -gltsym 'SYM:.5*cue_ld3 -.5*cue_ld1' -glt_label 2 cue_load \
        \
        \
        -overwrite \
        -x1D Xmat_${prefix}.x1D -x1D_uncensored uncensored_Xmat_${prefix}.x1D -xjpeg Xmat_image_$prefix.png \
	-fout -tout -rout -fitts fitts_${prefix} -errts errts_${prefix} -bucket stats_${prefix}


#Copy template ICBM152 (1x1x1) for underlay
ln -s /Volumes/Phillips/P5/group_analyses/WM/masks_and_templates/template.nii template.nii

#Run 3dREMLfit to obtain estimates for parameters after prewhitening of residuals (using a voxel-wise ARMA(1,1) model).
reml_cmd=stats_${prefix}.REML_cmd
reml_cmd_edited=${reml_cmd}_edited
sed 's/-tout/-GOFORIT 99 -tout/' $reml_cmd> $reml_cmd_edited #add -GOFORIT & jobs options (used '-tout' arbitrarily, as insertion point)
chmod 777 $reml_cmd_edited
./$reml_cmd_edited

#Old syntax for running 3dREMLfit
#input=$sdir/preproc/$pattern/nfswudktm_working*_5.nii.gz
#3dREMLfit -matrix Xmat.x1D \
#-GOFORIT 4 \
#-input $input \
#-fout -tout -Rbuck stats_REML -Rvar stats_REMLvar \
#-Rfitts fitts_REML -Rerrts errts_REML -verb $*
