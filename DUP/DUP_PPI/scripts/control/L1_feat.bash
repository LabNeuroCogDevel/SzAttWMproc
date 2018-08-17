#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
export FSLPARALLEL="" # running in parallel issue
cd $(dirname $0) # start in script (control) dir

#
# run feat model for ROI and a single run (L1), working memory preprocessed 4d nifti
#   get id and run number from input file
# using delay

usage() {
   [ -n "$1" ] && echo "ERROR: $1"
   echo "USAGE:"
   echo "$0 template ROI pathto/nfswudktm_workingmemory_[12]_5.nii.gz"
   echo "run feat model on given working memory preprocess nifti. expect lunaid in name"
   exit
}

## check input
[[ -z "$3" || $1 =~ ^-*help ]] && usage 

# get template
feattemplate="$1";shift
[[ ! -r $feattemplate || ! $feattemplate =~ .fsf$ ]] && usage "bad feat template: $feattemplate"

# roi makes sense
roi="$1";shift
grep "^$roi$" txt/rois.txt -q || usage "$roi not in txt/rois.txt"


# input nifiti makes sense
in_nii="$1";
[ -z "$in_nii" -o ! -r "$in_nii" ] && usage "need workingmemory nifti"
in_nii=$(cd $(dirname $in_nii);pwd)/$(basename $in_nii)
shift

# check lunaid
[[ $in_nii =~ [0-9]{5}_[0-9]{8} ]] || usage "$in_nii has no lunaid!?"
lunaid=${BASH_REMATCH}

# check run
[[ $in_nii =~ ([1-2])_5.nii.gz?$ ]] || usage "$in_nii has no run number!?"
run=${BASH_REMATCH[1]}

# always using delay

# do we have the timeseries file we need
timeseries=$(pwd)/roi_ts/${lunaid}_${roi}_wm$run.txt
[ ! -r $timeseries ] && echo "missing $lunaid $run time series: $timeseries!" && exit 1

# what we call the desgin file and the feat output folder
tmpltstr=$(basename $feattemplate .fsf|sed 's/_\?template//') # delay_L1_template_sepload.fsf -> delay_L1_sepload
design_string="WM${run}_${roi}_$tmpltstr"

subjdir=$(pwd)/PPI/$lunaid

outputdir="$subjdir/$design_string"
outfolder="$outputdir.feat" 
grep Finished $outfolder/report.html -q 2>/dev/null && echo have finished $outfolder && exit

# also check if we have repeat runs ( +.feat), and bail if we do
extra="$(ls -d $outputdir+*.feat 2>/dev/null)" || :
[ -n "$extra" ] && echo "already run, weirdness happening, skipping b/c $extra" && exit 1

# remove if we have and we want to redo (REMOVEFILES set to yes) -- only redo if incomplete b/c of above checks
[ "$REMOVEFILES" == "yes" -a -d $outfolder ] && rm -r $outfolder
[ -d  $outfolder ] && echo "have unfinished $outfolder" && exit 1

[ -n "$DRYRUN" ] && echo DRYRUN. would create $outfolder && exit 

featfile=$subjdir/$design_string.fsf
[ ! -d $subjdir ] && mkdir -p $subjdir

sed -e "s:SUBJECTID:$lunaid:g" \
    -e "s:INPUTFILE:$in_nii:g" \
    -e "s:OUTPUTDIR:$outputdir:g"\
    -e "s:TIMESERIES:$timeseries:g" \
    -e "s:RUNNUMBER:$run:g" \
    $feattemplate  > $featfile

echo "$design_string: $outfolder: start $(date +%F) $(date +%s)"
feat $featfile 
echo "$design_string: $outfolder: finished $(date +%F) $(date +%s)"

#  SUBJECTID for timing files like /Volumes/Phillips/P5/DUP/DUP_PPI/subj/10843_20151015/1d/WM/correct_load_wrongtogether_dlymod/cue_ld1_Correct_run1.stim
#  INPUTFILE was /Volumes/Phillips/P5/DUP/DUP_PPI/subj/10843_20151015/preproc/workingmemory_1/nfswudktm_workingmemory_1_5
#  OUTPUTDIR was /Volumes/Phillips/P5/DUP/DUP_PPI/subj/10843_20151015/PPI_run1_delay_LDC
#  TIMESERIES was /Volumes/Phillips/P5/DUP/DUP_PPI/subj/10843_20151015/timeseries/WM/SUBJECTID_LDC_wm1.txt
#  RUNNUMBER was 2
