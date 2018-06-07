#!/usr/bin/env bash

# 20180607 WF - build file list of structurals to send to ginger for CTMHR student processing

rsync -azvhiL .. sarpaldlab@10.128.174.46:/media/sarpaldlab/lab/data/P5_struct/ --files-from=<( cat  <<ENDSUBJ |
11358_20150129
11340_20141031
11354_20141205
11355_20141230
11357_20150122
11363_20150310
11368_20150505
11386_20150619
11407_20150716
11423_20150916
11433_20150924
11432_20150922
11454_20151019
11466_20151125
11418_20151201
11473_20151217
11477_20160108
11476_20151219
11479_20160108
11483_20160128
11485_20160112
11505_20160216
11532_20160413
11534_20160418
11539_20160430
11545_20160518
11552_20160611
11563_20160718
11572_20160819
11580_20161021
11585_20161203
11587_20161207
11594_20170111
11596_20170125
11604_20170317
11614_20170711
11339_20141104
11424_20150908
11341_20141118
11349_20141124
11352_20141230
11356_20150105
11360_20150129
11359_20150203
11228_20150309
11365_20150407
11374_20150529
11390_20150721
10843_20151015
11500_20160215
11511_20160307
11277_20160311
11452_20160404
11525_20160412
11524_20160425
11512_20160510
11556_20160705
11559_20160719
11465_20160711
ENDSUBJ
while read subj; do
   t1dir=$(ls -d ../subj/$subj/tfl*)
   [ ! -r $t1dir ] && echo "missing dir for $subj $t1dir" >&2
   echo "$t1dir/"
done )
