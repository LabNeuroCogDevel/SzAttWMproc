#!/usr/bin/env bash

#
# Preprocess subject
# arguments:
#  1) subject (full directory if not run from same dir)
#  2) run (e.g. attention1)
# 
# * expect there to be a subfolder called MB
# * expect mprage to be tfl-multiecho-epinav-711-RMS_256x192.8/

# run like: ./preprocessOne.bash btc_08222014 attention_1
# 


scriptdir=$(cd $(dirname $0);pwd)

# find subject
s=$1
[ ! -d "$s" ] && s=$scriptdir/$1
[ ! -d "$s" ] && echo "cannot find subj dir ($1 or $s)" && exit 1

cd $s
sdir=$(pwd);
s=$(basename $sdir)

# make sure we have 1d files
oneddir=$sdir/1d
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

contrasts=$sdir/contrasts/
[ ! -d "$contrasts" ] && mkdir $contrasts

cd $contrasts
model="BLOCK(.5,1)" # everything we model is .5s long
set -xe

prefix=simpledContrasts

3dDeconvolve  \
        -input $sdir/preproc/attention_[123]/nfswdktm_attention_[123]_5.nii.gz \
	-CENSORTR <( cat $sdir/preproc/attention_*/motion_info/censor_union.1D) \
	\
	-num_stimts 9 \
	-stim_times 1 $oneddir/attend_tPopout.1D   "$model"  -stim_label 1 attend_pop \
	-stim_times 2 $oneddir/attend_tHabitual.1D "$model"  -stim_label 2 attend_hab \
	-stim_times 3 $oneddir/attend_tFlexible.1D "$model"  -stim_label 3 attend_flx \
	-stim_times 4 $oneddir/probe_tPopout.1D    "$model"  -stim_label 4 probe_pop  \
	-stim_times 5 $oneddir/probe_tHabitual.1D  "$model"  -stim_label 5 probe_hab  \
	-stim_times 6 $oneddir/probe_tFlexible.1D  "$model"  -stim_label 6 probe_flx  \
	-stim_times 7 $oneddir/cue_tPopout.1D      "$model"  -stim_label 7 cue_pop    \
	-stim_times 8 $oneddir/cue_tHabitual.1D    "$model"  -stim_label 8 cue_hab    \
	-stim_times 9 $oneddir/cue_tFlexible.1D    "$model"  -stim_label 9 cue_flx    \
	\
	-num_glt 12 \
	-gltsym 'SYM:.333*attend_flx +.333*attend_hab +.333*attend_pop' -glt_label 1 att         \
	-gltsym 'SYM:.5*attend_hab -.5*attend_pop'                      -glt_label 2 att_habVpop \
	-gltsym 'SYM:.5*attend_flx -.5*attend_pop'                      -glt_label 3 att_flxVpop \
	-gltsym 'SYM:.5*attend_flx -.5*attend_hab'                      -glt_label 4 att_flxVhab \
	-gltsym 'SYM:.333*probe_flx +.333*probe_hab +.333*probe_pop'    -glt_label 5 prb         \
	-gltsym 'SYM:.5*probe_hab -.5*probe_pop'                        -glt_label 6 prb_habVpop \
	-gltsym 'SYM:.5*probe_flx -.5*probe_pop'                        -glt_label 7 prb_flxVpop \
	-gltsym 'SYM:.5*probe_flx -.5*probe_hab'                        -glt_label 8 prb_flxVhab \
	-gltsym 'SYM:.333*cue_flx +.333*cue_hab +.333*cue_pop'          -glt_label 9  cue         \
	-gltsym 'SYM:.5*cue_hab -.5*cue_pop'                            -glt_label 10 cue_habVpop \
	-gltsym 'SYM:.5*cue_flx -.5*cue_pop'                            -glt_label 11 cue_flxVpop \
	-gltsym 'SYM:.5*cue_flx -.5*cue_hab'                            -glt_label 12 cue_flxVhab \
	\
	-overwrite \
	-fout -tout -x1D Xmat.x1D -fitts ${prefix}_fitts -bucket ${prefix}_stats
	
# we want to have a template too
[ -r template.nii ] || ln -s $(readlink $sdir/tfl-multiecho-*/template_brain.nii) template.nii

