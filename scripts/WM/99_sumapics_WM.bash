#!/usr/bin/env bash
set -e
scriptdir=$(cd $(dirname $0); pwd)

function DriveAFNI {
   plugout_drive -quit -com "$@" >/dev/null 2>&1
   sleep 1;
}

pval=30

#what key shows only that hemisphere
# for LH we want to disable the RH
LH='['
RH=']'

stdbrain=/Users/mariaj/abin/standard
# where to get contrasts
dsetdir=/Volumes/Phillips/P5/group_analyses/WM/ttest_WM_bycorrect_load_wrongtogether_dlymod_2016-04-04/
# where to save images
imgdir=/Volumes/Phillips/P5/group_analyses/WM/ttest_WM_bycorrect_load_wrongtogether_dlymod_2016-04-04/imgs
[ ! -d "$imgdir" ] && mkdir $imgdir

# where is the mni template brain surf and nii
export specFile=$stdbrain/suma_mni/N27_both.spec
export t1image=$stdbrain/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_brain_2mm.nii


#### start suma
if ! pidof afni && ! pidof suma; then
   suma -niml -spec $specFile -sv $t1image &

   afni -niml -yesplugouts \
        -com "SET_UNDERLAY $t1image" \
        -dset $t1image $dsetdir/*HEAD &

   sleep 20

   DriveSuma -com  viewer_cont \
     -key F3 \
     -key F6 \
     -key:r:3 z   \
     -key:r:3 t \
   #     -key:r:7 period \
   #     -key ctrl+left\

   sleep 10
fi


####
#### are we ready?
####
DriveSuma -com  viewer_cont -key ctrl+up
cat <<HEREDOC

*********************************


is everything the way you want it
 
 * is suma recording?
 * are both hemispheres visible?
 
 * are the clusters set
 * colors selected?


*********************************
[push enter]

HEREDOC
read
####


# for each task, we load a new nifti
for task in delay_ld1 delay_ld3; do

 file=$dsetdir/$task+tlrc.HEAD

 # skip this task if we deon't have a file (error)
 [ ! -r "$file" ] && \
   echo "cannot read task $task file: $file" && continue

 # otherwise set afni to use this
 image=$(basename $file .HEAD)
 DriveAFNI "SET_OVERLAY $image"


 # disable both hemis -- empty picture
 # toggle the one we want inside it's loop
 DriveSuma -com  viewer_cont -key "[" -key "]"

 sleep 1


 for msb in 2 4; do
   # t-stat sub brick is one above mean/contrast brick
   tsb=$((($msb+1)))

   # set subbrick and threshold
   DriveAFNI "SET_SUBBRICKS -1 $msb $tsb"
   DriveAFNI "SET_THRESHNEW .$pval *p"


   echo
   echo "******************************"
   echo "*"
   echo "* setting $image briks:  $msb $tsb"
   echo "*"
   echo "******************************"
   echo

   # contrast allows for signed values
   # otherise (means): only show pos
   if [ $msb -eq 0 ]; then
    DriveAFNI "SET_PBAR_SIGN -"
    echo "* "
    echo "* signed"
    echo "* "
   else
    DriveAFNI "SET_PBAR_SIGN +"
    echo "* "
    echo "* positive only"
    echo "* "
   fi
   sleep 1



   for direction in left right; do
     DriveSuma -com  viewer_cont -key ctrl+$direction
     for hemi in RH LH; do
       hkey="${!hemi}"

       DriveSuma -com  viewer_cont -key "$hkey"

       echo "******************************"
       echo "*"
       echo "*  set hemi to $hemi by pushing '$hkey'"
       echo "*"
      
       # we want hemi direction and sub brick to be in save name
       savename="$imgdir/${image%+tlrc}_${hemi}_${direction}_$msb.jpg"


       echo "** saving to $(basename $savename)"
    
       DriveSuma -com recorder_cont \
                 -save_as "$savename" 
    
    

      # toggle visible hemisphere back off
      DriveSuma -com  viewer_cont -key $hkey

     done # HEMI
     # get both hemis back
     DriveSuma -com  viewer_cont -key "[" -key "]"

    done # direction

  done # subbrick (msb tsb)


done # task

# give back the hemis
DriveSuma -com  viewer_cont -key "[" -key "]"
