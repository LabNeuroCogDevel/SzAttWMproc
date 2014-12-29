#!/usr/bin/env bash
set -xe

#
# GLM for WM
# arguments:
#  1) subject (full directory if not run from same dir)
#  2) pattern (default: working_memory_X[12] )
# 
# * expect there to be a subfolder called MB
# * expect mprage to be tfl-multiecho-epinav-711-RMS_256x192.8/

# run like: ./preprocessOne.bash btc_08222014 attention_1
# 


scriptdir=$(cd $(dirname $0);pwd)

# find subject
s=$1
[ -z "$s" ] && echo "need a subject directory as first argument!" && exit 1
[ ! -d "$s" ] && s=$scriptdir/$1
[ ! -d "$s" ] && echo "cannot find subj dir ($1 or $s)" && exit 1

cd $s
sdir=$(pwd);
s=$(basename $sdir)

# make sure we have 1d files
oneddir=$sdir/1d/WM
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

contrasts=$sdir/contrasts/WM
[ ! -d "$contrasts" ] && mkdir -p $contrasts

cd $contrasts


# how do we model things
model="BLOCK(.5,1)"     # most are .5s long
ldmodel="BLOCK(3,1)"    # long  delay is 3s
sdmodel="BLOCK(1,1)"    # short delay is 1s
pmodel="BLOCK(1,1)"     # given 1s to respond in probe


prefix=${s}_WM_DefaultContrasts


# make sure we only have 2 runs in each of the stims
[ -d 1d ] && rm -r 1d
mkdir 1d

#{Response.1D,cue_ld4_sd1.1D,delay_ld1_sd2.1D,fix.1D,probe_ld1_sd2_chg0.1D,probe_ld4_sd1_chg1.1D,cue_ld1_sd1.1D,cue_ld4_sd2.1D,delay_ld4_sd1.1D,probe_ld1_sd1_chg0.1D,probe_ld1_sd2_chg1.1D,probe_ld4_sd2_chg0.1D,cue_ld1_sd2.1D,delay_ld1_sd1.1D,delay_ld4_sd2.1D,probe_ld1_sd1_chg1.1D,probe_ld4_sd1_chg0.1D,probe_ld4_sd2_chg1.1D}
for od in $oneddir/{fix,Response,cue_ld{1,4}_sd{1,2},delay_ld{1,4}_sd{1,2}_dly{0,1},probe_ld{1,4}_sd{1,2}_chg{0,1}}.1D ; do
	[ ! -r $od ] && echo missing 1d file $od && exit 1
	head -n2 $od > 1d/$(basename $od)
done

pattern=working_memory_X[12]
[ -n "$2" ] && pattern=$2

3dDeconvolve  \
        -input $sdir/preproc/$pattern/nfswdktm_working*_5.nii.gz \
	-CENSORTR <( cat $sdir/preproc/$pattern/motion_info/censor_union.1D) \
	\
	-num_stimts 21 \
	-stim_times 1  1d/cue_ld1_sd1.1D        "$model"   -stim_label 1    cAm_1l1s\
	-stim_times 2  1d/cue_ld1_sd2.1D        "$model"   -stim_label 2    cAm_1l2s\
	-stim_times 3  1d/cue_ld4_sd1.1D        "$model"   -stim_label 3    cAm_4l1s\
	-stim_times 4  1d/cue_ld4_sd2.1D        "$model"   -stim_label 4    cAm_4l2s\
	-stim_times 5  1d/delay_ld1_sd1_dly0.1D "$sdmodel" -stim_label 5    dly_1l1s_s\
	-stim_times 6  1d/delay_ld1_sd2_dly0.1D "$sdmodel" -stim_label 6    dly_1l2s_s\
	-stim_times 7  1d/delay_ld4_sd1_dly0.1D "$sdmodel" -stim_label 7    dly_4l1s_s\
	-stim_times 8  1d/delay_ld4_sd2_dly0.1D "$sdmodel" -stim_label 8    dly_4l2s_s\
	-stim_times 9  1d/delay_ld1_sd1_dly1.1D "$ldmodel" -stim_label 9    dly_1l1s_l\
	-stim_times 10 1d/delay_ld1_sd2_dly1.1D "$ldmodel" -stim_label 10   dly_1l2s_l\
	-stim_times 11 1d/delay_ld4_sd1_dly1.1D "$ldmodel" -stim_label 11   dly_4l1s_l\
	-stim_times 12 1d/delay_ld4_sd2_dly1.1D "$ldmodel" -stim_label 12   dly_4l2s_l\
	-stim_times 13 1d/probe_ld1_sd1_chg0.1D "$pmodel"  -stim_label 13   prb_1l1s0c\
	-stim_times 14 1d/probe_ld1_sd2_chg0.1D "$pmodel"  -stim_label 14   prb_1l2s0c\
	-stim_times 15 1d/probe_ld4_sd1_chg0.1D "$pmodel"  -stim_label 15   prb_4l1s0c\
	-stim_times 16 1d/probe_ld4_sd2_chg0.1D "$pmodel"  -stim_label 16   prb_4l2s0c\
	-stim_times 17 1d/probe_ld1_sd1_chg1.1D "$pmodel"  -stim_label 17   prb_1l1s1c\
	-stim_times 18 1d/probe_ld1_sd2_chg1.1D "$pmodel"  -stim_label 18   prb_1l2s1c\
	-stim_times 19 1d/probe_ld4_sd1_chg1.1D "$pmodel"  -stim_label 19   prb_4l1s1c\
	-stim_times 20 1d/probe_ld4_sd2_chg1.1D "$pmodel"  -stim_label 20   prb_4l2s1c\
	-stim_times 21 1d/Response.1D           "$model"   -stim_label 21   rspbtn_.5blk\
	\
	-num_glt 23  \
	-gltsym 'SYM:.25*cAm_1l1s +.25*cAm_1l2s +.25*cAm_4l1s +.25*cAm_4l2s'             -glt_label 1  cue_mem  \
	\
	-gltsym 'SYM:.125*dly_1l1s_s +.125*dly_1l2s_s +.125*dly_4l1s_s +.125*dly_4l2s_s 
                    +.125*dly_1l1s_l +.125*dly_1l2s_l +.125*dly_4l1s_l +.125*dly_4l2s_s' -glt_label 2  dly       \
	-gltsym 'SYM:.25*dly_1l1s_s +.25*dly_1l2s_s +.25*dly_4l1s_s +.25*dly_4l2s_s'     -glt_label 3  dly_short \
	-gltsym 'SYM:.25*dly_1l1s_l +.25*dly_1l2s_l +.25*dly_4l1s_l +.25*dly_4l2s_s'     -glt_label 4  dly_long  \
	-gltsym 'SYM:.25*dly_1l1s_s +.25*dly_1l2s_s +.25*dly_1l1s_l +.25*dly_1l2s_l'     -glt_label 5  dly_load1 \
	-gltsym 'SYM:.25*dly_4l1s_s +.25*dly_4l2s_s +.25*dly_4l1s_l +.25*dly_4l2s_l'     -glt_label 6  dly_load4 \
	-gltsym 'SYM:.25*dly_1l1s_s +.25*dly_4l1s_s +.25*dly_4l1s_l +.25*dly_4l1s_l'     -glt_label 7  dly_left \
	-gltsym 'SYM:.25*dly_1l2s_s +.25*dly_4l2s_s +.25*dly_4l2s_l +.25*dly_4l2s_l'     -glt_label 8  dly_right \
	\
	-gltsym 'SYM:.125*prb_1l1s0c +.125*prb_1l2s0c +.125*prb_4l1s0c +.125*prb_4l2s0c 
                    +.125*prb_1l1s1c +.125*prb_1l2s1c +.125*prb_4l1s1c +.125*prb_4l2s0c' -glt_label 9  prb       \
	-gltsym 'SYM:.25*prb_1l1s0c +.25*prb_1l2s0c +.25*prb_4l1s0c +.25*prb_4l2s0c'     -glt_label 10 prb_same  \
	-gltsym 'SYM:.25*prb_1l1s1c +.25*prb_1l2s1c +.25*prb_4l1s1c +.25*prb_4l2s0c'     -glt_label 11 prb_chg   \
	-gltsym 'SYM:.25*prb_1l1s0c +.25*prb_1l2s0c +.25*prb_1l1s1c +.25*prb_1l2s1c'     -glt_label 12 prb_load1  \
	-gltsym 'SYM:.25*prb_4l1s0c +.25*prb_4l2s0c +.25*prb_4l1s1c +.25*prb_4l2s1c'     -glt_label 13 prb_load4  \
	-gltsym 'SYM:.25*prb_1l1s0c +.25*prb_4l1s0c +.25*prb_1l1s1c +.25*prb_4l1s1c'     -glt_label 14 prb_left  \
	-gltsym 'SYM:.25*prb_1l2s0c +.25*prb_4l2s0c +.25*prb_1l2s1c +.25*prb_4l2s1c'     -glt_label 15 prb_right  \
	\
	-gltsym 'SYM:.125*dly_1l1s_s +.125*dly_1l2s_s +.125*dly_4l1s_s +.125*dly_4l2s_s 
                    +.125*dly_1l1s_l +.125*dly_1l2s_l +.125*dly_4l1s_l +.125*dly_4l2s_s
	            -.25*cAm_1l1s    -.25*cAm_1l2s    -.25*cAm_4l1s    -.25*cAm_4l2s'    -glt_label 16  dlyVcue_mem  \
	\
	-gltsym 'SYM:.125*prb_1l1s0c +.125*prb_1l2s0c +.125*prb_4l1s0c +.125*prb_4l2s0c 
                    +.125*prb_1l1s1c +.125*prb_1l2s1c +.125*prb_4l1s1c +.125*prb_4l2s0c
                    -.125*dly_1l1s_s -.125*dly_1l2s_s -.125*dly_4l1s_s -.125*dly_4l2s_s 
                    -.125*dly_1l1s_l -.125*dly_1l2s_l -.125*dly_4l1s_l -.125*dly_4l2s_s' -glt_label 17  prbVdly    \
	\
	-gltsym 'SYM:.125*prb_1l1s0c +.125*prb_1l2s0c +.125*prb_4l1s0c +.125*prb_4l2s0c 
                    +.125*prb_1l1s1c +.125*prb_1l2s1c +.125*prb_4l1s1c +.125*prb_4l2s0c
	            -.25*cAm_1l1s    -.25*cAm_1l2s    -.25*cAm_4l1s    -.25*cAm_4l2s'    -glt_label 18 prbVcue_mem  \
	\
	-gltsym 'SYM:.125*prb_4l1s0c +.125*prb_4l2s0c +.125*prb_4l1s1c +.125*prb_4l2s1c     
	            -.125*prb_1l1s0c -.125*prb_1l2s0c -.125*prb_1l1s1c -.125*prb_1l2s1c' -glt_label 19 prb_load4M1  \
        \
	-gltsym 'SYM:.125*prb_1l1s0c +.125*prb_4l1s0c +.125*prb_1l1s1c +.125*prb_4l1s1c
	            -.125*prb_1l2s0c -.125*prb_4l2s0c -.125*prb_1l2s1c -.125*prb_4l2s1c' -glt_label 20 prb_leftMright \
	\
	-gltsym 'SYM:.125*prb_1l1s1c +.125*prb_1l2s1c +.125*prb_4l1s1c +.125*prb_4l2s0c
	            -.125*prb_1l1s0c -.125*prb_1l2s0c -.125*prb_4l1s0c -.125*prb_4l2s0c' -glt_label 21 prb_chgMsame \
         \
	-gltsym 'SYM:.125*dly_4l1s_s +.125*dly_4l2s_s +.125*dly_4l1s_l +.125*dly_4l2s_l
	            -.125*dly_1l1s_s -.125*dly_1l2s_s -.125*dly_1l1s_l -.125*dly_1l2s_l' -glt_label 22 dly_load4M1 \
	\
	-gltsym 'SYM:.25*cAm_4l1s +.25*cAm_4l2s -.25*cAm_1l1s -.25*cAm_1l2s'             -glt_label 23 cAm_load4M1  \
	-overwrite \
	-fout -tout -x1D Xmat.x1D -fitts ${prefix}_fitts -bucket ${prefix}_stats
	
# we want to have a template too
[ -r template.nii ] || ln -s $(readlink $sdir/tfl-multiecho-*/template_brain.nii) template.nii

