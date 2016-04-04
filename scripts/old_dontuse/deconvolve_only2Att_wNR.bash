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

prefix=contrasts_modelinc_2runs_wNR


# make sure we only have 2 runs in each of the stims
#WF/MJ 20150429- also create a file if there isn't a wrong file (i.e., they didn't get any wrong)
[ -d 1d ] && rm -r 1d
mkdir 1d
for od in $oneddir/{cue,attend,probe}_t{Habitual,Flexible,Popout}_c{Wrong,Correct}.1D; do
       [ ! -r $od ] && echo -e "*\n*" > $od
       head -n2 $od > 1d/$(basename $od)
done

cd $oneddir
#20150508 make a total incorrect file (Michael's suggestion)
#for some weird reason 1dcat changes the * to zeroes, and we don't want that in there
1dcat cue_tPopout_cWrong.1D attend_tPopout_cWrong.1D probe_tPopout_cWrong.1D cue_tHabitual_cWrong.1D attend_tHabitual_cWrong.1D probe_tHabitual_cWrong.1D | sed 's/^ 0/*/; s/ 0//g' > total_Incorrect.1D

#MJ 20150429 took out don't need right now
#also get a block regressor
#for t in Popout Habitual Flexible; do
 # cut -f 1 -d ' ' 1d/cue_t${t}.1D > 1d/block_t${t}.1D
  # print duration
  #echo "== $t =="
  #perl -slane '$end=$F[$#F] + 1.5; print sprintf("\t%.3f to %.3f dur (%.3f)", $F[0], $end, $end-$F[0])' <(paste 1d/cue_t${t}.1D 1d/probe_t${t}.1D)
#done

cd $contrasts





pattern=attention_[12]
[ -n "$2" ] && pattern=$2



3dDeconvolve  \
        -input $sdir/preproc/$pattern/nfswudktm_${pattern}_5.nii.gz \
	-CENSORTR <( cat $sdir/preproc/attention_*/motion_info/censor_union.1D) \
	\
	-allzero_OK \
	-GOFORIT 4 \
	-num_stimts 14 \
	-stim_times 1 $oneddir/cue_tPopout_cCorrect.1D   "$model"  -stim_label 1 cue_pop_cor \
	-stim_times 2 $oneddir/attend_tPopout_cCorrect.1D "$model"  -stim_label 2 att_pop_cor \
	-stim_times 3 $oneddir/probe_tPopout_cCorrect.1D "$model"  -stim_label 3 prb_pop_cor \
	-stim_times 4 $oneddir/cue_tHabitual_cCorrect.1D   "$model"  -stim_label 4 cue_hab_cor \
	-stim_times 5 $oneddir/attend_tHabitual_cCorrect.1D "$model"  -stim_label 5 att_hab_cor \
	-stim_times 6 $oneddir/probe_tHabitual_cCorrect.1D "$model"  -stim_label 6 prb_hab_cor \
	-stim_times 7 $oneddir/cue_tFlexible_cCorrect.1D   "$model"  -stim_label 7 cue_flx_cor \
	-stim_times 8 $oneddir/attend_tFlexible_cCorrect.1D   "$model"  -stim_label 8 att_flx_cor \
	-stim_times 9 $oneddir/probe_tFlexible_cCorrect.1D   "$model"  -stim_label 9 prb_flx_cor \
	-stim_times 10 $oneddir/total_Incorrect.1D "$model"  -stim_label 10 total_incorrect \
	-stim_file 11  $sdir/preproc/$pattern/nuissance_regressors.txt[1] -stim_label 11 csf \
        -stim_file 12 $sdir/preproc/$pattern/nuissance_regressors.txt[2] -stim_label 12 dcsf \
        -stim_file 13  $sdir/preproc/$pattern/nuissance_regressors.txt[3] -stim_label 13 wm \
	-stim_file 14  $sdir/preproc/$pattern/nuissance_regressors.txt[4] -stim_label 14 dwm
	-num_glt 12 \
	-gltsym 'SYM:.333*cue_pop_cor +.333*cue_hab_cor +.333*cue_flx_cor' -glt_label 1 cue \
	-gltsym 'SYM:.333*att_pop_cor +.333*att_hab_cor +.333*att_flx_cor' -glt_label 2 att \
	-gltsym 'SYM:.333*prb_pop_cor +.333*prb_hab_cor +.333*prb_flx_cor' -glt_label 3 prb \
	-gltsym 'SYM:.5*att_hab_cor -.5*att_pop_cor'                    -glt_label 4 att_habVpop \
	-gltsym 'SYM:.5*att_flx_cor -.5*att_pop_cor'                    -glt_label 5 att_flxVpop \
	-gltsym 'SYM:.5*att_flx_cor -.5*att_hab_cor'                    -glt_label 6 att_flxVhab \
	-gltsym 'SYM:.5*cue_hab_cor -.5*cue_pop_cor'                    -glt_label 7 cue_habVpop \
	-gltsym 'SYM:.5*cue_flx_cor -.5*cue_pop_cor'                    -glt_label 8 cue_flxVpop \
	-gltsym 'SYM:.5*cue_flx_cor -.5*cue_hab_cor'                    -glt_label 9 cue_flxVhab \
	-gltsym 'SYM:.5*prb_hab_cor -.5*prb_pop_cor'                    -glt_label 10 prb_habVpop \
	-gltsym 'SYM:.5*prb_flx_cor -.5*prb_pop_cor'                    -glt_label 11 prb_flxVpop \
	-gltsym 'SYM:.5*prb_flx_cor -.5*prb_hab_cor'                    -glt_label 12 prb_flxVhab \
	-overwrite \
	-xjpeg design_matrix.png \
	-fout -tout -x1D ${prefix}_Xmat.x1D -fitts ${prefix}_fitts -bucket ${prefix}_stats
	
# we want to have a template too
[ -r template.nii ] || ln -s $(readlink $sdir/tfl-multiecho-*/template_brain.nii) template.nii

#REMLfit cmd, getting rid of temporal autocorrelation, may want to use
#3dREMLfit -matrix ${prefix}_Xmat.x1D \
 #-input  -input $sdir/preproc/$pattern/nfswdktm_${pattern}_5.nii.gz \
 #-Rbuck ${prefix}_Decon_REML -Rvar ${prefix}_Decon_REMLvar -verb $*
