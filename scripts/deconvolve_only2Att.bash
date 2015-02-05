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
oneddir=$sdir/1d/Att
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

contrasts=$sdir/contrasts/Att
[ ! -d "$contrasts" ] && mkdir -p $contrasts

cd $contrasts
model="BLOCK(.5,1)" # everything we model is .5s long
bmodel="BLOCK(96,1)" # blocks are about 95 seconds long (91--100)

prefix=simpledContrasts_2runs


# make sure we only have 2 runs in each of the stims
[ -d 1d ] && rm -r 1d
mkdir 1d
for od in $oneddir/{attend_tPopout.1D,attend_tHabitual.1D,attend_tFlexible.1D,probe_tPopout.1D,probe_tHabitual.1D,probe_tFlexible.1D,cue_tPopout.1D,cue_tHabitual.1D,cue_tFlexible.1D}; do 
	head -n2 $od > 1d/$(basename $od)
done

#also get a block regressor
for t in Popout Habitual Flexible; do
  cut -f 1 -d ' ' 1d/cue_t${t}.1D > 1d/block_t${t}.1D
  # print duration
  echo "== $t =="
  perl -slane '$end=$F[$#F] + 1.5; print sprintf("\t%.3f to %.3f dur (%.3f)", $F[0], $end, $end-$F[0])' <(paste 1d/cue_t${t}.1D 1d/probe_t${t}.1D)
done


pattern=attention_[12]
[ -n "$2" ] && pattern=$2


3dDeconvolve  \
        -input $sdir/preproc/$pattern/nfswdktm_${pattern}_5.nii.gz \
	-CENSORTR <( cat $sdir/preproc/attention_*/motion_info/censor_union.1D) \
	\
	-num_stimts 12 \
	-stim_times 1 1d/attend_tPopout.1D   "$model"  -stim_label 1 attend_pop \
	-stim_times 2 1d/attend_tHabitual.1D "$model"  -stim_label 2 attend_hab \
	-stim_times 3 1d/attend_tFlexible.1D "$model"  -stim_label 3 attend_flx \
	-stim_times 4 1d/probe_tPopout.1D    "$model"  -stim_label 4 probe_pop  \
	-stim_times 5 1d/probe_tHabitual.1D  "$model"  -stim_label 5 probe_hab  \
	-stim_times 6 1d/probe_tFlexible.1D  "$model"  -stim_label 6 probe_flx  \
	-stim_times 7 1d/cue_tPopout.1D      "$model"  -stim_label 7 cue_pop    \
	-stim_times 8 1d/cue_tHabitual.1D    "$model"  -stim_label 8 cue_hab    \
	-stim_times 9 1d/cue_tFlexible.1D    "$model"  -stim_label 9 cue_flx    \
	-stim_times 10 1d/block_tPopout.1D   "$bmodel"  -stim_label 10 blk_pop   \
	-stim_times 11 1d/block_tHabitual.1D "$bmodel"  -stim_label 11 blk_hab   \
	-stim_times 12 1d/block_tFlexible.1D "$bmodel"  -stim_label 12 blk_flx   \
	\
	-num_glt 16 \
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
	-gltsym 'SYM:.333*blk_flx +.333*blk_hab +.333*blk_pop'          -glt_label 13 blk         \
	-gltsym 'SYM:.5*blk_hab -.5*blk_pop'                            -glt_label 14 blk_habVpop \
	-gltsym 'SYM:.5*blk_flx -.5*blk_pop'                            -glt_label 15 blk_flxVpop \
	-gltsym 'SYM:.5*blk_flx -.5*blk_hab'                            -glt_label 16 blk_flxVhab \
	\
	-overwrite \
	-fout -tout -x1D Xmat.x1D -fitts ${prefix}_fitts -bucket ${prefix}_stats
	
# we want to have a template too
[ -r template.nii ] || ln -s $(readlink $sdir/tfl-multiecho-*/template_brain.nii) template.nii

