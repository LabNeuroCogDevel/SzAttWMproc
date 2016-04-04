#!/usr/bin/env bash
#set -xe

# Edited  01/28/16 by Pati- looking at diff trial length
# GLM for Attention
# arguments:
#  1) subject (full directory if not run from same dir)
# 
# * expect there to be a subfolder called MB
# * expect mprage to be tfl-multiecho-epinav-711-RMS_256x192.8/


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
oneddir=$sdir/1d/Att/bycorrect_longcatch
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

contrasts=$sdir/contrasts/Att
[ ! -d "$contrasts" ] && mkdir -p $contrasts

cd $contrasts
model="BLOCK(1.0,1)" # cue + attend  is 1.0s long
pmodel="BLOCK(0.6,1)" # 01/28/16 average RT is 609 ms long
incmodel="BLOCK(1.5,1)" #approx length of an incorrect trial

prefix=bycond_caonly_wlc_tprobe



# make sure we only have 2 runs in each of the stims
#WF/MJ 20150429- also create a file if there isn't a wrong file (i.e., they didn't get any wrong)
for od in $oneddir/{cue,attend,probe}_t{Habitual,Flexible,Popout}_c{Wrong,Correct}.1D; do
       if [ ! -s $od ]; then
           echo $od
	   echo -e "*\n*" > $od
       fi
#       head -n2 $od > $oneddir/$(basename $od)
done


cd $oneddir
#20150508 make a total incorrect file (Michael's suggestion)

#for some weird reason 1dcat changes the * to zeroes, and we don't want that in there
#1dcat cue_tPopout_cWrong.1D cue_tHabitual_cWrong.1D cue_tFlexible_cWrong.1D | sed 's/ 0//g; s/^$/*/' > total_Incorrect.1D

#make total incorrect file with times in order
timing_tool.py -timing cue_tPopout_cWrong.1D -extend cue_tHabitual_cWrong.1D -extend cue_tFlexible_cWrong.1D -sort -write_timing total_Incorrect.1D

#20160128 make total probe file
#1dcat probe_tPopout_cCorrect.1D probe_tHabitual_cCorrect.1D probe_tFlexible_cCorrect.1D > total_Probe.1D

#make total probe file with times in order
timing_tool.py -timing probe_tPopout_cCorrect.1D -extend probe_tHabitual_cCorrect.1D -extend probe_tFlexible_cCorrect.1D -sort -write_timing total_Probe.1D

#combine cue popout trial w/ long catches
timing_tool.py -timing cue_tPopout_cCorrect.1D -extend cue_tPopout_cLongCatch.1D -sort -write_timing cue_tPopout_cCorrect_wlc.1D

#combine cue habitual trial w/ long catches
timing_tool.py -timing cue_tHabitual_cCorrect.1D -extend cue_tHabitual_cLongCatch.1D -sort -write_timing cue_tHabitual_cCorrect_wlc.1D

#combine cue flexible trial w/ long catches
timing_tool.py -timing cue_tFlexible_cCorrect.1D -extend cue_tFlexible_cLongCatch.1D -sort -write_timing cue_tFlexible_cCorrect_wlc.1D

cd $contrasts


#combine the censor files into 1 big censor file
cat $sdir/preproc/attention_1/motion_info/censor_union.1D $sdir/preproc/attention_2/motion_info/censor_union.1D > censor_total.1D



pattern=attention_[12]
[ -n "$2" ] && pattern=$2

grep -c \* $oneddir/total_Incorrect.1D
nInc="$(grep -c \* $oneddir/total_Incorrect.1D | cut -d: -f2)"


if [ $nInc -ne 2 ]; then
    echo "here I am"
  3dDeconvolve \
    -input $sdir/preproc/$pattern/nfswudktm_${pattern}_5.nii.gz \
    -mask /Users/lncd/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c_2.3mm.nii \
    -jobs 12 \
    -censor censor_total.1D \
    -num_stimts 8 \
    -stim_times 1 $oneddir/cue_tPopout_cCorrect_wlc.1D   "$model"  -stim_label 1 Popout_ca_wlc \
    -stim_times 2 $oneddir/cue_tHabitual_cCorrect_wlc.1D "$model"  -stim_label 2 Habitual_ca_wlc \
    -stim_times 3 $oneddir/cue_tFlexible_cCorrect_wlc.1D "$model"  -stim_label 3 Flexible_ca_wlc \
    -stim_times 4 $oneddir/cue_tPopout_cCatch.1D   "$model"  -stim_label 4 Popout_catch \
    -stim_times 5 $oneddir/cue_tHabitual_cCatch.1D "$model"  -stim_label 5 Habitual_catch \
    -stim_times 6 $oneddir/cue_tFlexible_cCatch.1D "$model"  -stim_label 6 Flexible_catch \
    -stim_times 7 $oneddir/total_Probe.1D "$pmodel" -stim_label 7 total_probe \
    -stim_times 8 $oneddir/total_Incorrect.1D "$incmodel" -stim_label 8 total_incorrect \
    -num_glt 3 \
    -gltsym 'SYM:.5*Habitual_ca_wlc -.5*Popout_ca_wlc'                    -glt_label 1 HabvPop \
    -gltsym 'SYM:.5*Flexible_ca_wlc -.5*Popout_ca_wlc'                    -glt_label 2 FlexvPop \
    -gltsym 'SYM:.5*Flexible_ca_wlc -.5*Habitual_ca_wlc'                    -glt_label 3 FlexvHab \
    -overwrite \
    -xjpeg dm_${prefix}.png \
    -fout -tout -x1D ${prefix}_Xmat.x1D -bucket ${prefix}_stats

else

  3dDeconvolve  \
    -input $sdir/preproc/$pattern/nfswudktm_${pattern}_5.nii.gz \
    -mask /Users/lncd/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c_2.3mm.nii \
    -jobs 12 \
    -censor censor_total.1D \
    -num_stimts 7 \
    -stim_times 1 $oneddir/cue_tPopout_cCorrect_wlc.1D   "$model"  -stim_label 1 Popout_ca_wlc \
    -stim_times 2 $oneddir/cue_tHabitual_cCorrect_wlc.1D "$model"  -stim_label 2 Habitual_ca_wlc \
    -stim_times 3 $oneddir/cue_tFlexible_cCorrect_wlc.1D "$model"  -stim_label 3 Flexible_ca_wlc \
    -stim_times 4 $oneddir/cue_tPopout_cCatch.1D   "$model"  -stim_label 4 Popout_catch \
    -stim_times 5 $oneddir/cue_tHabitual_cCatch.1D "$model"  -stim_label 5 Habitual_catch \
    -stim_times 6 $oneddir/cue_tFlexible_cCatch.1D "$model"  -stim_label 6 Flexible_catch \
    -stim_times 7 $oneddir/total_Probe.1D "$pmodel" -stim_label 7 total_probe \
    -num_glt 3 \
    -gltsym 'SYM:.5*Habitual_ca_wlc -.5*Popout_ca_wlc'                    -glt_label 1 HabvPop \
    -gltsym 'SYM:.5*Flexible_ca_wlc -.5*Popout_ca_wlc'                    -glt_label 2 FlexvPop \
    -gltsym 'SYM:.5*Flexible_ca_wlc -.5*Habitual_ca_wlc'                    -glt_label 3 FlexvHab \
    -overwrite \
    -xjpeg dm_${prefix}.png \
    -fout -tout -x1D ${prefix}_Xmat.x1D -bucket ${prefix}_stats

fi

      


	
# we want to have a template too
ln -s /Volumes/Phillips/P5/group_analyses/WM/masks_and_templates/template.nii template.nii
