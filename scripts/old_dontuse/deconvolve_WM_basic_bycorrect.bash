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
oneddir=$sdir/1d/WM/correct_load_wrongtogether
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
dmodel="dmUBLOCK(1)"    # cue is a variable length block covering ISI & mem; variable length, but fixed amplitude
ldmodel="BLOCK(3,1)"    # long  delay is 3s
sdmodel="BLOCK(1,1)"    # short delay is 1s
pmodel="BLOCK(2,1)"     # probe is 2s
model="BLOCK(.5,1)"     #garbage model

prefix=${s}_basic_WM

pattern=working*[12]
[ -n "$2" ] && pattern=$2

3dDeconvolve \
    -input $sdir/preproc/$pattern/nfsw*_working*_5.nii.gz \
    -allzero_OK \
    -GOFORIT 99 \
    -singvals \
    -jobs 8 \
    -polort 3 \
    -censor censor_total.1D \
    -num_stimts 7 \
        -stim_times_AM1 1 $oneddir/cue_ld1_Correct.1D "$dmodel" -stim_label 1 cue_ld1 \
        -stim_times_AM1 2 $oneddir/cue_ld3_Correct.1D "$dmodel" -stim_label 2 cue_ld3 \
        -stim_times 3 $oneddir/delay_ld1_Correct.1D "$sdmodel" -stim_label 3 delay_ld1 \
        -stim_times 4 $oneddir/delay_ld3_Correct.1D "$ldmodel" -stim_label 4 delay_ld3 \
        -stim_times 5 $oneddir/probe_ld1_Correct.1D "$pmodel" -stim_label 5 probe_ld1 \
        -stim_times 6 $oneddir/probe_ld3_Correct.1D "$pmodel" -stim_label 6 probe_ld3 \
	-stim_times 7 $oneddir/Wrong.1D "$model" -stim_label 7 Wrong \
	\
	-num_glt 3 \
        -gltsym 'SYM: +cue_ld1 +cue_ld3' -glt_label 1 cue  \
        -gltsym 'SYM: +delay_ld1 +delay_ld3' -glt_label 2 delay \
        -gltsym 'SYM: +probe_ld1 +probe_ld3' -glt_label 3 probe \
        -overwrite \
        -x1D Xmat_${prefix}.x1D -x1D_uncensored uncensored_Xmat_${prefix}.x1D -xjpeg Xmat_image_$prefix.png \
	-fout -tout -fitts fitts_${prefix} -errts errts_${prefix} -bucket stats_${prefix}

	
# we want to have a template too
[ -r template.nii ] || ln -s $(readlink $sdir/tfl-multiecho-*/template_brain.nii) template.nii
