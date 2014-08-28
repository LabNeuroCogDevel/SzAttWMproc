#!/usr/bin/env bash

#
# Preprocess subject
# arguments:
#  1) subject (full directory if not run from same dir)
#  2) run (e.g. attention1)
# 
# * expect there to be a subfolder called MB
# * expect mprage to be tfl-multiecho-epinav-711-RMS_256x192.8/

warp=mprage_warpcoef.nii.gz
bet=mprage_bet.nii.gz
timing1d=/Volumes/Serena/SPECC/MR_Raw/speccMBTimings.1D 
TR=1.0

scriptdir=$(cd $(dirname $0);pwd)

# find subject
s=$1
[ ! -d "$s" ] && s=$scriptdir/$1
[ ! -d "$s" ] && echo "cannot find subj dir ($1 or $s)" && exit 1

cd $s
sdir=$(pwd);
s=$(dirname $sdir)

# find run
runname=$2
[ -z "$2" ] && echo "need a second argument: what run?" && exit 1
run=$(ls $sdir/MB/*$2*hdr|grep -v ref|tail -n1)
[ ! -r "$run" ] && echo "cannot find run dir ($run)" && exit 1


set -xe


mpragedir=$(ls -d tfl-multiecho-epinav-711-RMS_256x192*/|tail -n1)
## MRAGE first
[ ! -d "$mpragedir" ] && echo "no $mpragedir" && exit 1 

cd $mpragedir
[ ! -r "$warp" -o ! -r "$bet" ] && echo "running mprage!" && echo "or not" 
wait
[ ! -r "$warp" -o ! -r "$bet" ] && echo "mprage preproc failed!" && exit 1
cd -

## run preproc

# move from ANALYZE to niifty
ppdir=$sdir/preproc/$runname
[ ! -d $ppdir ] && mkdir -p  $ppdir
cd $ppdir

[ ! -r $runname.nii.gz ] && 3dcopy $run $runname.nii.gz
# reset TR
3drefit -TR $TR $runname.nii.gz

echo preprocessFunctional -4d *.nii.gz -tr $TR -mprage_bet $mpragedir/$bet -warpcoef $mpragedir/$warp -threshold 98_2 -hp_filter 100 -rescaling_method 10000_globalmedian -template_brain MNI_2.3mm -func_struc_dof bbr -warp_interpolation spline -constrain_to_template y -wavelet_despike -4d_slice_motion -custom_slice_times $timing1d -mc_movie -motion_censor fd=0.9,dvars=20
# dont have fieldmap!
# -fm_phase /Volumes/Serena/MMClock/MR_Raw/10638_20140507/gre_field_mapping_new_96x90.15/MR* -fm_magnitude /Volumes/Serena/MMClock/MR_Raw/10638_20140507/gre_field_mapping_new_96x90.14/MR* -fm_cfg clock 
