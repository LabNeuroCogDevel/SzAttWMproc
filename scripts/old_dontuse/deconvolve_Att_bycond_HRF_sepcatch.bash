#!/usr/bin/env bash
#set -xe

#
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
model="TENT(0,20,21)" # trial is 1.5s long

prefix=bycond_HRF_sepcatch




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
#make total incorrect file with times in order
timing_tool.py -timing cue_tPopout_cWrong.1D -extend cue_tHabitual_cWrong.1D -extend cue_tFlexible_cWrong.1D -sort -write_timing total_Incorrect.1D


cd $contrasts


#combine the censor files into 1 big censor file
cat $sdir/preproc/attention_1/motion_info/censor_union.1D $sdir/preproc/attention_2/motion_info/censor_union.1D > censor_total.1D


pattern=attention_[12]
[ -n "$2" ] && pattern=$2

grep -c \* $oneddir/total_Incorrect.1D
nInc=$(grep -c \* $oneddir/total_Incorrect.1D | cut -d: -f2)

echo $nInc

if [ $nInc -ne 2 ]; then
  3dDeconvolve  \
    -input $sdir/preproc/$pattern/nfswudktm_${pattern}_5.nii.gz \
    -mask /Users/lncd/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c_2.3mm.nii \
    -jobs 12 \
    -GOFORIT 99 \
    -censor censor_total.1D \
    -num_stimts 10 \
    -stim_times 1 $oneddir/cue_tPopout_cCorrect.1D   "$model"  -stim_label 1 Popout \
    -stim_times 2 $oneddir/cue_tHabitual_cCorrect.1D "$model"  -stim_label 2 Habitual \
    -stim_times 3 $oneddir/cue_tFlexible_cCorrect.1D "$model"  -stim_label 3 Flexible \
    -stim_times 4 $oneddir/cue_tPopout_cCatch.1D   "$model"  -stim_label 4 Popout_scatch \
    -stim_times 5 $oneddir/cue_tHabitual_cCatch.1D "$model"  -stim_label 5 Habitual_scatch \
    -stim_times 6 $oneddir/cue_tFlexible_cCatch.1D "$model"  -stim_label 6 Flexible_scatch \
    -stim_times 7 $oneddir/cue_tPopout_cLongCatch.1D   "$model"  -stim_label 7 Popout_lcatch \
    -stim_times 8 $oneddir/cue_tHabitual_cLongCatch.1D "$model"  -stim_label 8 Habitual_lcatch \
    -stim_times 9 $oneddir/cue_tFlexible_cLongCatch.1D "$model"  -stim_label 9 Flexible_lcatch \
    -stim_times 10 $oneddir/total_Incorrect.1D "$model"  -stim_label 10 totalIncorrect \
    -iresp 1 "HRF2_Popout" \
    -iresp 2 "HRF2_Habitual" \
    -iresp 3 "HRF2_Flexible" \
    -iresp 4 "HRF2_Popout_scatch" \
    -iresp 5 "HRF2_Habitual_scatch" \
    -iresp 6 "HRF2_Flexible_scatch" \
    -iresp 7 "HRF2_Popout_lcatch" \
    -iresp 8 "HRF2_Habitual_lcatch" \
    -iresp 9 "HRF2_Flexible_lcatch" \
    -iresp 10 "HRF2_total_incorrect" \
    -overwrite \
    -xjpeg dm_{prefix}.png \
    -fout -tout -x1D ${prefix}_Xmat.x1D -bucket ${prefix}_stats

else

  3dDeconvolve  \
    -input $sdir/preproc/$pattern/nfswudktm_${pattern}_5.nii.gz \
    -mask /Users/lncd/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_gm_tal_nlin_asym_09c_2.3mm.nii \
    -jobs 12 \
    -GOFORIT 99 \
    -censor censor_total.1D \
    -num_stimts 9 \
    -stim_times 1 $oneddir/cue_tPopout_cCorrect.1D   "$model"  -stim_label 1 Popout \
    -stim_times 2 $oneddir/cue_tHabitual_cCorrect.1D "$model"  -stim_label 2 Habitual \
    -stim_times 3 $oneddir/cue_tFlexible_cCorrect.1D "$model"  -stim_label 3 Flexible \
    -stim_times 4 $oneddir/cue_tPopout_cCatch.1D   "$model"  -stim_label 4 Popout_scatch \
    -stim_times 5 $oneddir/cue_tHabitual_cCatch.1D "$model"  -stim_label 5 Habitual_scatch \
    -stim_times 6 $oneddir/cue_tFlexible_cCatch.1D "$model"  -stim_label 6 Flexible_scatch \
    -stim_times 7 $oneddir/cue_tPopout_cLongCatch.1D   "$model"  -stim_label 7 Popout_lcatch \
    -stim_times 8 $oneddir/cue_tHabitual_cLongCatch.1D "$model"  -stim_label 8 Habitual_lcatch \
    -stim_times 9 $oneddir/cue_tFlexible_cLongCatch.1D "$model"  -stim_label 9 Flexible_lcatch \
    -iresp 1 "HRF2_Popout" \
    -iresp 2 "HRF2_Habitual" \
    -iresp 3 "HRF2_Flexible" \
    -iresp 4 "HRF2_Popout_scatch" \
    -iresp 5 "HRF2_Habitual_scatch" \
    -iresp 6 "HRF2_Flexible_scatch" \
    -iresp 7 "HRF2_Popout_lcatch" \
    -iresp 8 "HRF2_Habitual_lcatch" \
    -iresp 9 "HRF2_Flexible_lcatch" \
    -overwrite \
    -xjpeg dm_${prefix}.png \
    -fout -tout -x1D ${prefix}_Xmat.x1D -bucket ${prefix}_stats

fi

	
