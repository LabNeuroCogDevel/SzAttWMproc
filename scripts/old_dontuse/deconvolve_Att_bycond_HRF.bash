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
oneddir=$sdir/1d/Att/bycorrect
[ ! -d "$oneddir" ] && echo "cannot find 1d dir ($oneddir)" && exit 1
echo $oneddir

contrasts=$sdir/contrasts/Att
[ ! -d "$contrasts" ] && mkdir -p $contrasts

cd $contrasts
model="TENT(0,20,21)" # trial is 1.5s long

prefix=bycond_HRF




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
1dcat cue_tPopout_cWrong.1D cue_tHabitual_cWrong.1D cue_tFlexible_cWrong.1D | sed 's/ 0//g; s/^$/*/' > total_Incorrect.1D

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
    -num_stimts 7 \
    -stim_times 1 $oneddir/cue_tPopout_cCorrect.1D   "$model"  -stim_label 1 Popout \
    -stim_times 2 $oneddir/cue_tHabitual_cCorrect.1D "$model"  -stim_label 2 Habitual \
    -stim_times 3 $oneddir/cue_tFlexible_cCorrect.1D "$model"  -stim_label 3 Flexible \
    -stim_times 4 $oneddir/cue_tPopout_cCatch.1D   "$model"  -stim_label 4 Popout_catch \
    -stim_times 5 $oneddir/cue_tHabitual_cCatch.1D "$model"  -stim_label 5 Habitual_catch \
    -stim_times 6 $oneddir/cue_tFlexible_cCatch.1D "$model"  -stim_label 6 Flexible_catch \
    -stim_times 7 $oneddir/total_Incorrect.1D "$model" -stim_label 7 total_incorrect \
    -iresp 1 "HRF2_Popout" \
    -iresp 2 "HRF2_Habitual" \
    -iresp 3 "HRF2_Flexible" \
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
    -num_stimts 6 \
    -stim_times 1 $oneddir/cue_tPopout_cCorrect.1D   "$model"  -stim_label 1 Popout \
    -stim_times 2 $oneddir/cue_tHabitual_cCorrect.1D "$model"  -stim_label 2 Habitual \
    -stim_times 3 $oneddir/cue_tFlexible_cCorrect.1D "$model"  -stim_label 3 Flexible \
    -stim_times 4 $oneddir/cue_tPopout_cCatch.1D   "$model"  -stim_label 4 Popout_catch \
    -stim_times 5 $oneddir/cue_tHabitual_cCatch.1D "$model"  -stim_label 5 Habitual_catch \
    -stim_times 6 $oneddir/cue_tFlexible_cCatch.1D "$model"  -stim_label 6 Flexible_catch \
    -iresp 1 "HRF2_Popout" \
    -iresp 2 "HRF2_Habitual" \
    -iresp 3 "HRF2_Flexible" \
    -overwrite \
    -xjpeg dm_${prefix}.png \
    -fout -tout -x1D ${prefix}_Xmat.x1D -bucket ${prefix}_stats

fi

	
