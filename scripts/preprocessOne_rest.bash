#!/usr/bin/env bash

#
# Preprocess subject
# arguments:
#  1) subject_visit or full directory
#  2) run (e.g. attention1)
#  3) savename (optional, defaults to run)
# 
# * expect there to be a subfolder called MB
# * expect mprage to be tfl-multiecho-epinav-711-RMS_256x192.8/

# run like: ./preprocessOne.bash btc_08222014 attention_1
# 
# to redo even if we already have final output
# REDO=1 ./preprocessOne.bash btc_08222014 attention_1

# where can we find warping output
warp=mprage_warpcoef.nii.gz
bet=mprage_bet.nii.gz
# what defines the slice acquisition sequenction
timing1d=/Volumes/Phillips/P5/scripts/sliceTimings.1D
# actual TR, 3dcopy of hdr doesn't maintain TR in header
TR=1.0
# what does the final nii.gz start with
finalpfix="nfswudktm"

scriptdir=$(cd $(dirname $0);pwd)
subjdir=$(cd $scriptdir/../subj;pwd)
echo "[$(date +"%F %H:%M"):$(pwd)] $0 $@" >> $scriptdir/log.txt

# find subject
s=$1
[ ! -d "$s" ] && s=$subjdir/$1
[ ! -d "$s" ] && echo "cannot find subj dir ($1 or $s)" && exit 1

#go into subject's directory
cd $s
#set the directory
sdir=$(pwd);
s=$(dirname $sdir)
s2=$(basename $sdir)

# find run (i.e., attention_X1, attention_X2)
[ -z "$2" ] && echo "need a second argument: what run?" && exit 1
runname=$2


if [ -n "$3" ]; then savename=$3; else savename=$runname; fi
[ -z "$savename" ] && echo "no savename (2nd or 3rd argument)" && exit 1

#looking for the run file inside /Volumes/Phillips/P5/subj/11327_20140911
#run=$(ls $sdir/MB/*$runname*hdr|grep -v ref|tail -n1)
run=$(find  $sdir/MB/ -maxdepth 1 -iname "*$runname*hdr" -and -not -iname '*ref.hdr'|tail -n1)
[ -z "$run" -o ! -r "$run" ] && echo "cannot find run.hdr  ($sdir/MB/*$runname*hdr)" && exit 1


## ref image
refimg=$(find  $sdir/MB/ -maxdepth 1 -iname "*$runname*ref.hdr"|tail -n1)
[ -z "$refimg" -o ! -r "$refimg" ] && echo "cannot find run_ref.hdr  ($sdir/MB/*runname*_ref.hdr)" && exit 1

## Field maps
# first mag then phase
# -fm_magnitude "/Volumes/Phillips/P5/subj/$s2/gre_field_mapping_new_96x90.13/MR*" 
# -fm_phase "/Volumes/Phillips/P5/subj/$s2/gre_field_mapping_new_96x90.14/MR*" 
fms=( $( find $sdir -maxdepth 1 -iname 'gre_field_mapping_new_9[06]x9[60].*' |tail -n2  ) )
[ ${#fms[@]} -ne 2 ] && echo "cannot find mag and phase in $sdir/gre_field_mapping_new_9[06]x9[60].*" && exit 1

fm_mag=${fms[0]}
fm_phase=${fms[1]}

# check we have the right directories (based on dicom count)
[ ! -r $fm_mag/.fieldmap_magnitude  -a \
  $(ls $fm_mag/MR*  |wc -l) -ne 120   ] && 
 echo "fm_mag does not have 120 MRs or .fieldmap_magnitude! ($fm_mag)"   && exit 1

nphase=$(ls $fm_phase/MR* | wc -l|sed 's/ //g')
[ ! -r $fm_phase/.fieldmap_phase ] && 
  [  $nphase -ne 60 ] && 
  echo "fm_mag does not have  60 MRs ($nphase) and no .fieldmap_phase file! ($fm_phase)" && exit 1

set -xe


## MPRAGE first
#set mprage directory
#command tail outputs the last part, or "tail", of files
mpragedir=$(ls -d tfl-multiecho-*/|tail -n1)
#if the above command is blank then come back with no mpragedir
[ ! -d "$mpragedir" ] && echo "no $mpragedir" && exit 1 
#go into mprage directory
cd $mpragedir
mpragedir=$(pwd)

[ ! -r "$warp" -o ! -r "$bet" ] && echo "running mprage!" && preprocessMprage -d archive -r MNI_2mm -p "MR*"
wait # prob dont need this
[ ! -r "$warp" -o ! -r "$bet" ] && echo "mprage preproc failed!" && exit 1
cd -


## Start Preproc

# set preproc save dir
ppdir=$sdir/preproc/$savename
[ ! -d $ppdir ] && mkdir -p  $ppdir
cd $ppdir

# test we haven't done this before if we dont explicitly say to REDO
if [ -z "$REDO" ]; then
  fc=$(find . -iname "${finalpfix}_*.nii.gz"|wc -l)

  [[ "$fc" -ge "2" ]] && echo "already have ${finalpfix}_* ('$fc'), consider 
  REDO=1 $0 $@ 
or removing $(pwd)/${finalpfix}_*" && exit 1
fi

# move from ANALYZE to niifty
[ ! -r $savename.nii.gz ] && 3dcopy $run $savename.nii.gz

# reset TR
TRreported=$(3dinfo -tr $savename.nii.gz)
diff=$(echo "$TRreported - $TR" | bc -l )
# can not use -eq 0 becuase diff might be non-digit (e.g. ".5")
[[ "$diff" != "0" ]] &&  3drefit -TR $TR $savename.nii.gz

# we do not want to do slicetiming again.. it takes forever and we trust it
#[ -r .temporal_filtering_complete ] && \
#  find . -mindepth 1 -maxdepth 1 -newer .temporal_filtering_complete -exec rm -r {} \;

# actually preproc
echo "preproc $s $savename ($ppdir)"

preprocessFunctional -4d $savename.nii.gz -tr $TR \
	 -mprage_bet $mpragedir/$bet -warpcoef $mpragedir/$warp \
	 -threshold 98_2 -bandpass_filter .009 .08 \
	 -rescaling_method 10000_globalmedian \
	 -delete_dicom no \
	 -template_brain MNI_2.3mm -func_struc_dof bbr -warp_interpolation spline \
	 -constrain_to_template y -wavelet_despike -wavelet_m1000 -wavelet_threshold 10 \
	 -4d_slice_motion -custom_slice_times $timing1d -mc_movie \
	 -motion_censor fd=0.5,dvars=5 -nuisance_regression 6motion,csf,wm,dcsf,dwm \
         -nuisance_file nuisance_regressors.txt \
	 -nuisance_compute csf,dcsf,wm,dwm \
	 -func_refimg $refimg \
	 -fm_phase "$fm_phase/MR*" -fm_magnitude "$fm_mag/MR*" \
	 -fm_cfg clock \
         -startover


# everything is okay!
exit 0
