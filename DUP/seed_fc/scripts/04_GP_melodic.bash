#!/usr/bin/env bash

###
#04_GP_melodic.bash - makes masked whole brain resting state file for each subject then runs melodic on the group to look at GP - GP connectivity
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash

#NOTE: edited 5/14/18 to create masked resting state files for LGP and RGP separately

cd $(dirname $0)


# a list of subjects
#DUPLIST=DUP.lst 
CONTROLLIST=Controls.lst

#both/l/r?
GP=RGP


# GP mask
GPmask=/Volumes/Phillips/P5/DUP/seed_fc/GP_seeds_fromAtlas_FINAL/${GP}.nii.gz

# #PATIENTS
# cat $DUPLIST | while read subj dup; do
#   restfile=/Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/brnswudktm_rest_5.nii.gz 
# 
#   # test if file does not exist -- when it doesnt say so and go to next id (continue)
#   if [ ! -r $restfile ]; then 
#      echo "cannot find $restfile" 
#      continue
#   fi
# 
#   echo "processing $subj"
# 
#    #3dcalc to make "mask" with values only in GP and zeros everywhere else
#   3dcalc -a $restfile -m $GPmask -expr 'step(m)*a' -prefix ${subj:0:5}_melodicinput.nii.gz
# 
#   done
# 
   #CONTROLS
 cat $CONTROLLIST | while read subj; do
   restfile=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/brnswudktm_rest_5.nii.gz 
   
   echo $subj
   
   
   # done
   # test if file does not exist -- when it doesnt say so and go to next id (continue)                                                 echo "done."
   if [ ! -r $restfile ]; then 
      echo "cannot find $restfile" 
      continue
   fi
 
   echo "processing $subj"
 

    #3dcalc to make "mask" with values only in GP and zeros everywhere else
   3dcalc -a $restfile -m $GPmask -expr 'step(m)*a' -prefix ${subj:0:5}_${GP}_melodicinput.nii.gz
 
   done













