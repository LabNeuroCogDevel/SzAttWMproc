#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

#
# combine WM1 and WM2 for L2 feat
#
# ./L2_feat.bash L2_template.fsf PPI/11602_20170228/WM[12]_LDC_delay_L1_sepload.feat/
[ "$#" -ne 3 ] && echo "USAGE: $0 L2_template.fsf path_to/run1.feat path_to/run2.feat" && exit 1
feattemplate="$1";shift
[[ ! -r $feattemplate || ! $feattemplate =~ .fsf$ ]] && usage "bad feat template: $feattemplate"

WM1feat="$1";shift
WM2feat="$1";shift
# check each feat
for feat in WM{1,2}feat; do
  # check exists
  [ ! -d ${!feat} ] && echo "bad dir for $feat: ${!feat}" && exit 1
  # check finished
  ! grep Finished ${!feat}/report.html -q 2>/dev/null && echo "not finished ${!feat}" && exit
  # check reg 
  [ ! -d ${!feat}/reg ] && echo "not reg, consider 030_reg_normal.bash ${!feat}" && exit
  # make absolute
  printf -v $feat "$(cd $(dirname ${!feat});pwd)/$(basename ${!feat})"
done

[ $(dirname $WM1feat) != $(dirname $WM2feat) ] && echo "WM1 and WM2 have different roots?! probably not what you want" && exit 1

subjdir=$(dirname $WM1feat)

design_string=$(basename $feattemplate .fsf|sed 's/_\?template//')_$(basename $WM1feat .feat|sed -e 's/_\?L1//' -e 's/_\?WM[12]/WM/')
# e.g. L2_WM_LDC_delay_sepload

echo $design_string

# check we are running feat for the first time
outputdir="$subjdir/$design_string"
outfolder="$outputdir.gfeat" 


grep Finished $outfolder/report.html -q 2>/dev/null && echo have finished $outfolder && exit

# also check if we have repeat runs ( +.gfeat), and bail if we do
extra="$(ls -d $outputdir+*.gfeat 2>/dev/null)" || :
[ -n "$extra" ] && echo "already run, weirdness happening, skipping b/c $extra" && exit 1

# remove if we have and we want to redo (REMOVEFILES set to yes) -- only redo if incomplete b/c of above checks
[ "$REMOVEFILES" == "yes" -a -d $outfolder ] && rm -r $outfolder
[ -d  $outfolder ] && echo "have unfinished $outfolder" && exit 1

# update template
sed -e "s:WM1DIR:$WM1feat:g" \
    -e "s:WM2DIR:$WM2feat:g" \
    -e "s:OUTDIR:$outputdir:g" \
    $feattemplate > $outputdir.fsf

#run 2nd levels feat
feat $outputdir.fsf  
