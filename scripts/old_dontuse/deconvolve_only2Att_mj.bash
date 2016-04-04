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
model="BLOCK(.5,1)" # everything we model is .5s long
bmodel="BLOCK(96,1)" # blocks are about 95 seconds long (91--100)

prefix=simpledContrasts_2runs


# make sure we only have 2 runs in each of the stims
#WF/MJ 20150429- also create a file if there isn't a wrong file (i.e., they didn't get any wrong)
[ -d 1d ] && rm -r 1d
mkdir 1d
for od in $oneddir/{cue,attend,probe}_t{Habitual,Flexible,Popout}_c{Wrong,Correct}.1D; do
       [ ! -r $od ] && echo -e "*\n*" > $od
       head -n2 $od > 1d/$(basename $od)
done

#MJ 20150429 took out don't need right now
#also get a block regressor
#for t in Popout Habitual Flexible; do
 # cut -f 1 -d ' ' 1d/cue_t${t}.1D > 1d/block_t${t}.1D
  # print duration
  #echo "== $t =="
  #perl -slane '$end=$F[$#F] + 1.5; print sprintf("\t%.3f to %.3f dur (%.3f)", $F[0], $end, $end-$F[0])' <(paste 1d/cue_t${t}.1D 1d/probe_t${t}.1D)
#done


pattern=attention_[12]
[ -n "$2" ] && pattern=$2



3dDeconvolve  \
    -input $sdir/preproc/$pattern/nfswdktm_${pattern}_5.nii.gz \
	-CENSORTR <( cat $sdir/preproc/attention_*/motion_info/censor_union.1D) \
	\
	-num_stimts 9 \
	-stim_times 1 1d/attend_tPopout_cCorrect.1D   "$model"  -stim_label 1 att_pop_cor \
	-stim_times 2 1d/attend_tHabitual_cCorrect.1D "$model"  -stim_label 2 att_hab_cor \
	-stim_times 3 1d/attend_tFlexible_cCorrect.1D "$model"  -stim_label 3 att_flx_cor \
	-stim_times 4 1d/cue_tPopout_cCorrect.1D   "$model"  -stim_label 4 cue_pop_cor \
	-stim_times 5 1d/cue_tHabitual_cCorrect.1D "$model"  -stim_label 5 cue_hab_cor \
	-stim_times 6 1d/cue_tFlexible_cCorrect.1D "$model"  -stim_label 6 cue_flx_cor \
	-stim_times 7 1d/probe_tPopout_cCorrect.1D   "$model"  -stim_label 7 prb_pop_cor \
	-stim_times 8 1d/probe_tHabitual_cCorrect.1D   "$model"  -stim_label 8 prb_hab_cor \
	-stim_times 9 1d/probe_tFlexible_cCorrect.1D   "$model"  -stim_label 9 prb_flx_cor \
	-num_glt 9 \
	#-gltsym 'SYM:.'                                                 -glt_label 1 cue \
	#-gltsym 'SYM:.5*att_hab_cor -.5*att_pop_cor'                    -glt_label 1 att \
	#-gltsym 'SYM:.5*att_hab_cor -.5*att_pop_cor'                    -glt_label 1 probe \
	-gltsym 'SYM:.5*att_hab_cor -.5*att_pop_cor'                    -glt_label 1 att_habVpop \
	-gltsym 'SYM:.5*att_flx_cor -.5*att_pop_cor'                    -glt_label 2 att_flxVpop \
	-gltsym 'SYM:.5*att_flx_cor -.5*att_hab_cor'                    -glt_label 3 att_flxVhab \
	-gltsym 'SYM:.5*cue_hab_cor -.5*cue_pop_cor'                    -glt_label 4 cue_habVpop \
	-gltsym 'SYM:.5*cue_flx_cor -.5*cue_pop_cor'                    -glt_label 5 cue_flxVpop \
	-gltsym 'SYM:.5*cue_flx_cor -.5*cue_hab_cor'                    -glt_label 6 cue_flxVhab \
	-gltsym 'SYM:.5*prb_hab_cor -.5*prb_pop_cor'                    -glt_label 7 prb_habVpop \
	-gltsym 'SYM:.5*prb_flx_cor -.5*prb_pop_cor'                    -glt_label 8 prb_flxVpop \
	-gltsym 'SYM:.5*prb_flx_cor -.5*prb_hab_cor'                    -glt_label 9 prb_flxVhab \
	-overwrite \
	-fout -tout -x1D Xmat.x1D -fitts ${prefix}_fitts -bucket ${prefix}_stats2
        -xjpeg design_matrix.png
# we want to have a template too
[ -r template.nii ] || ln -s $(readlink $sdir/tfl-multiecho-*/template_brain.nii) template.nii

