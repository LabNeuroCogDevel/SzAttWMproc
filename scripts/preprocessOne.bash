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

warp=mprage_warpcoef.nii.gz
bet=mprage_bet.nii.gz
timing1d=/Volumes/Phillips/P5/sliceTimings.1D
TR=1.0

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

# find run (i.e., attention_X1, attention_X2)
[ -z "$2" ] && echo "need a second argument: what run?" && exit 1
runname=$2


if [ -n "$3" ]; then savename=$3; else savename=$runname; fi
[ -z "$savename" ] && echo "no savename (2nd or 3rd argument)" && exit 1

#looking for the run file inside /Volumes/Phillips/P5/subj/11327_20140911
run=$(ls $sdir/MB/*$runname*hdr|grep -v ref|tail -n1)
[ ! -r "$run" ] && echo "cannot find run dir ($run)" && exit 1


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

# test we haven't done this before
fc=$(find . -name 'nfswdktm_*.nii.gz'|wc -l)
[[ "$fc" -ge "2" ]] && echo "already have nfswdktm_*, consider removing $(pwd)/nfswdktm_* before running $0 $@" && exit 1

# move from ANALYZE to niifty
[ ! -r $savename.nii.gz ] && 3dcopy $run $savename.nii.gz

# reset TR
TRreported=$(3dinfo -tr $savename.nii.gz)
[[ "$TRreported" != "$TR" ]] &&  3drefit -TR $TR $savename.nii.gz


# actually preproc
echo "preproc $s $savename ($ppdir)"
preprocessFunctional -4d $savename.nii.gz -tr $TR -mprage_bet $mpragedir/$bet -warpcoef $mpragedir/$warp -threshold 98_2 -hp_filter 100 -rescaling_method 10000_globalmedian -template_brain MNI_2.3mm -func_struc_dof bbr -warp_interpolation spline -constrain_to_template y -wavelet_despike -4d_slice_motion -custom_slice_times $timing1d -mc_movie -motion_censor fd=0.9,dvars=20 -startover

# dont have fieldmap! 
# -fm_phase /Volumes/Serena/MMClock/MR_Raw/10638_20140507/gre_field_mapping_new_96x90.15/MR* -fm_magnitude /Volumes/Serena/MMClock/MR_Raw/10638_20140507/gre_field_mapping_new_96x90.14/MR* -fm_cfg clock 
