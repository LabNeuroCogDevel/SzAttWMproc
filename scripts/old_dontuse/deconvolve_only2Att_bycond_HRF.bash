#!/usr/bin/env bash
set -xe

#
# GLM for Attention
# arguments:
#  1) subject (full directory if not run from same dir)
# 
# * expect there to be a subfolder called MB
# * expect mprage to be tfl-multiecho-epinav-711-RMS_256x192.8/

# run like: ./preprocessOne.bash btc_08222014 attention_1
# 


scriptdir=$(cd $(dirname $0);pwd)
subjsdir=$scriptdir/../subj

# find subject
s=$1
[ -z "$s" ] && echo "need a subject directory as first argument!" && exit 1
[ ! -d "$s" ] && s=$scriptdir/$1
[ ! -d "$s" ] && s=$scriptdir/../$1
[ ! -d "$s" ] && s=$subjsdir/$1
[ ! -d "$s" ] && echo "cannot find subj dir ($1 or $s)" && exit 1

cd $s
sdir=$(pwd);
s=$(basename $sdir)

# make sure we have 1d files
oneddir=$sdir/1d/Att/correct_trialOnly
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

contrasts=$sdir/contrasts/Att
[ ! -d "$contrasts" ] && mkdir -p $contrasts

cd $contrasts
#first parameter:
#second paramter:
#third parameter: 
model="TENT(0,20,21)" # trail is 1.5s long


prefix=bycond_2runs_HRF




cd $contrasts

#combine the censor files into 1 big censor file
cat $sdir/preproc/attention_1/motion_info/censor_union.1D $sdir/preproc/attention_2/motion_info/censor_union.1D > censor_total.1D



pattern=attention_[12]
[ -n "$2" ] && pattern=$2



3dDeconvolve  \
    -input $sdir/preproc/$pattern/nfswudktm_${pattern}_5.nii.gz \
    -jobs 8 \
    -censor censor_total.1D \
    -num_stimts 3 \
    -stim_times 1 $oneddir/Popout.1D   "$model"  -stim_label 1 Popout \
    -stim_times 2 $oneddir/Habitual.1D "$model"  -stim_label 2 Habitual \
    -stim_times 3 $oneddir/Flexible.1D "$model"  -stim_label 3 Flexible \
    -iresp 1 "HRF_Popout" \
    -iresp 2 "HRF_Habitual" \
    -iresp 3 "HRF_Flexible" \
    -overwrite \
    -xjpeg design_matrix_${prefix}.png \
    -fout -tout -x1D ${prefix}_Xmat.x1D -bucket ${prefix}_stats
	
# we want to have a template too
[ -r template.nii ] || ln -s $(readlink $sdir/tfl-multiecho-*/template_brain.nii) template.nii

#REMLfit cmd, getting rid of temporal autocorrelation, may want to use
#3dREMLfit -matrix ${prefix}_Xmat.x1D \
 #-input $sdir/preproc/$pattern/nfswdktm_${pattern}_5.nii.gz \
 #-Rbuck ${prefix}_Decon_REML -Rvar ${prefix}_Decon_REMLvar -verb $*
