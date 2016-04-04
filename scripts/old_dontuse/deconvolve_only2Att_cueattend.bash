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
oneddir=$sdir/1d/Att/bycorrect_mrg
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

contrasts=$sdir/contrasts/Att
[ ! -d "$contrasts" ] && mkdir -p $contrasts

cd $contrasts
model1="BLOCK(1,1)" #cue + attend is 1 second long
model2="BLOCK(.5,,1)" # probe is .5 seconds long 


prefix=cattend_probe_2r #combined cue & attend, along with probe




cd $contrasts

#combine the censor files into 1 big censor file
cat $sdir/preproc/attention_1/motion_info/censor_union.1D $sdir/preproc/attention_2/motion_info/censor_union.1D > censor_total.1D


pattern=attention_[12]
[ -n "$2" ] && pattern=$2



3dDeconvolve  \
        -input $sdir/preproc/$pattern/nfswudktm_${pattern}_5.nii.gz \
	-censor censor_total.1D \
	-num_stimts 6 \
	-stim_times 1 $oneddir/cue_tPopout_cCorrect.1D   "$model1"  -stim_label 1 catt_pop_cor \
	-stim_times 2 $oneddir/probe_tPopout_cCorrect.1D "$model2"  -stim_label 2 prb_pop_cor \
	-stim_times 3 $oneddir/cue_tHabitual_cCorrect.1D   "$model1"  -stim_label 3 catt_hab_cor \
	-stim_times 4 $oneddir/probe_tHabitual_cCorrect.1D "$model2"  -stim_label 4 prb_hab_cor \
        -stim_times 5 $oneddir/cue_tFlexible_cCorrect.1D   "$model1"  -stim_label 5 catt_flx_cor \
	-stim_times 6 $oneddir/probe_tFlexible_cCorrect.1D "$model2"  -stim_label 6 prb_flx_cor \
	-num_glt 6 \
	-gltsym 'SYM:+catt_hab_cor -catt_pop_cor'     -glt_label 1 cattPopvcattHab \
	-gltsym 'SYM:+prb_hab_cor -prb_pop_cor'             -glt_label 2 prbHabvprbPop \
	-gltsym 'SYM:+catt_flx_cor -catt_hab_cor'      -glt_label 3 cueattFlxvcueattHab \
	-gltsym 'SYM:+prb_flx_cor -prb_hab_cor'              -glt_label 4 prbFlxvprbHab \
	-gltsym 'SYM:+catt_flx_cor -catt_pop_cor'      -glt_label 5 cueattFlxvcueattPop \
	-gltsym 'SYM:+prb_flx_cor -prb_pop_cor'              -glt_label 6 prbFlxvprbPop \
	-overwrite \
	-xjpeg design_matrix_${prefix}.png \
	-fout -tout -x1D ${prefix}_Xmat.x1D -fitts ${prefix}_fitts -bucket ${prefix}_stats
	
# we want to have a template too
[ -r template.nii ] || ln -s $(readlink $sdir/tfl-multiecho-*/template_brain.nii) template.nii

#REMLfit cmd, getting rid of temporal autocorrelation, may want to use
#3dREMLfit -matrix ${prefix}_Xmat.x1D \
 #-input $sdir/preproc/$pattern/nfswdktm_${pattern}_5.nii.gz \
 #-Rbuck ${prefix}_Decon_REML -Rvar ${prefix}_Decon_REMLvar -verb $*
