#!/usr/bin/env bash

# 3 group analysis- upperSCFU, lowerSCFU, controls

cd $(dirname $0)

#a list of masks
MASKLIST=GPmasks.lst

mask=/Volumes/Phillips/P5/DUP/seed_fc/groupROIanalyses/Control_GP_mask+tlrc

UPPER=upperSCFU.lst
LOWER=lowerSCFU.lst
controls=Controls.lst

prefix="-dset"
UPPERname=""
LOWERname=""
Controlsname=""


cat $MASKLIST | while read roi; do

cat $UPPER | while read subj;do
   UPPERname="$UPPERname $prefix 1 ../subjs/$subj/${subj:0:5}_${roi}_parc_corrmap_z+tlrc.HEAD "
done
UPPERname="$UPPERname 

cat $LOWER | while read subj;do
   LOWERname="$LOWERname $prefix 2 ../subjs/$subj/${subj:0:5}_${roi}_parc_corrmap_z+tlrc.HEAD "
done

cat $controls | while read subj;do
   Controlsname="$Controlsname $prefix 3 ../subjs/Controls/$subj/${subj:0:5}_${roi}_parc_corrmap_z+tlrc.HEAD "
done
   #output file name
#   name=../groupROIanalyses/${roi}_3group_CLUSTSIM

   #upperSCFU files
#   upperSCFU=../subjs/upperSCFU/1*_2*/1*_${roi}_parc_corrmap_z+tlrc.HEAD

   #lower SCFU files
#   lowerSCFU=../subjs/lowerSCFU/1*_2*/1*_${roi}_parc_corrmap_z+tlrc.HEAD

   #control files
#   controls=../subjs/Controls/1*_2*/1*_${roi}_parc_corrmap_z+tlrc.HEAD


#   3dANOVA -levels 3 $UPPERname $LOWERname $Controlsname

todo=""
todo="3dANOVA -levels 3 $UPPERname $LOWERname $Controlsname"

echo $todo

   done

