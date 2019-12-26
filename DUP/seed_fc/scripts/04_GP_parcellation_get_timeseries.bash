#!/usr/bin/env bash

###
#01_GP_parcellation_get_timeseries.bash - gets timeseries from each voxel in the mask
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


cd $(dirname $0)


# a list of subjects
DUPLIST=DUP.lst 
CONTROLLIST=Controls.lst

# a list of masks
#MASKLIST=2GPmasks.lst


# brain mask
brainmask=/Volumes/Phillips/P5/DUP/seed_fc/striatal_seeds_2.3m/mni_icbm152_t1_tal_nlin_asym_09c.nii

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
# #  for ROI in $(cat $MASKLIST); do
#      
#   ROImask=/Volumes/Phillips/P5/DUP/seed_fc/GP_seeds_fromAtlas_FINAL/${ROI}+tlrc.HEAD
# 
#   # mask ave
#   3dmaskave -q -udump -mask $ROImask $restfile |perl -ne 'chomp; print if ! /^\+/; print "\n" if m/ Average = ([.0-9-]+)/' | tee /Volumes/Phillips/P5/DUP/seed_fc/subjs/$subj/${subj:0:5}_LGP_voxelwise_ts_noAvg.1d
# 
#   done
# 
MASKLIST="LGP "
for ROI in $MASKLIST; do
   ROImask=/Volumes/Phillips/P5/DUP/seed_fc/GP_seeds_fromAtlas_FINAL/${ROI}.nii.gz
   [ ! -r $ROImask ] && echo "missing $ROImask" && continue
   
   cat $CONTROLLIST | while read subj; do
     restfile=/Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/brnswudktm_rest_5.nii.gz 
                                                                                                                                        # done
     # test if file does not exist -- when it doesnt say so and go to next id (continue)                                                 echo "done."
     if [ ! -r $restfile ]; then 
        echo "cannot find $restfile" 
        continue
     fi
   
     echo "processing $subj"
   
   
     # mask ave
     3dmaskave -q -udump -mask $ROImask $restfile |perl -ne 'chomp; print if ! /^\+/; print "\n" if m/ Average = ([.0-9-]+)/' | tee /Volumes/Phillips/P5/DUP/seed_fc/subjs/Controls/$subj/${subj:0:5}_${ROI}_voxelwise_ts_noAvg.1d
    
   done
done
