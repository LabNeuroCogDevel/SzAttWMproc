#!/usr/bin/env bash
set -xe


#Set list of subjects to run 3dREMLfit on (give numeric 'luna_date' name):
subj_list='11228_20150309 11348_20141119 11357_20150122 11349_20141124 11358_20150129 11368_20150505 11351_20141202 11359_20150203 11369_20150519 11352_20141230 11360_20150129 11374_20150529 11339_20141104 11354_20141205 11363_20150310 11386_20150619 11340_20141031 11355_20141230 11341_20141118 11356_20150105 11365_20150407 11407_20150716'

#NEED to run 11367_20150430 separately (needs re-preprocessing; missing fieldmap)
#NEED to run 11390_20150721 and 11402_20150728 separately (not yet preprocessed)
#EXCLUDE 11330_20141002 & 11364_20150317 (no data for tasks)
#EXCLUDE 11327_20140911 & 11333_20141017 (pilot tasks; no ISI)


#Loop over all subjects:

for i in $subj_list
do
    subj_path=/Volumes/Phillips/P5/subj/${i}
    pattern=workingmemory_[12]
    ./REMLfit_WM_wholetrial.bash $subj_path $pattern
done 






