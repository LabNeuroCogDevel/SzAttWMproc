#!/usr/bin/env bash

## mask script

cd $(dirname $0)

# a list of masks
MASKLIST=/Volumes/Phillips/P5/DUP/seed_fc/scripts/GPmasks.lst

cat $MASKLIST | while read mask; do

   maskFile=/Volumes/Phillips/P5/DUP/seed_fc/GP_seeds/notConverted/${mask}.nii.gz

   master=/Volumes/Phillips/P5/DUP/seed_fc/subjs/11340_20141031/brnswudktm_rest_5.nii.gz

   3dresample -rmode NN -prefix /Volumes/Phillips/P5/DUP/seed_fc/GP_seeds/${mask} -input $maskFile -master $master

done
