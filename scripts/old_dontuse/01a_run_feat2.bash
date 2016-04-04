#!/bin/sh

FSLDIR=/opt/ni_tools/fsl
. /opt/ni_tools/fsl/etc/fslconf/fsl.sh
PATH=$FSLDIR/bin:$PATH
export FSLDIR PATH

#location of subject data
DATA_ROOT=/Volumes/Phillips/P5/subj
FEAT_TEMPLATE_PATH=/Volumes/Phillips/P5/scripts/design/template_L1_WM_delay_PPI_R1.fsf

#your seed ROI
reg="RBA40"

ID="11358_20150129"
#11363_20150310"
#11359_20150203 11360_20150129 0"
#"11333_20141017"

#not run yet (run1 or run2)
# 

for i in ${ID}
	 do
    #go to designs directory
    cd /Volumes/Phillips/P5/scripts/design
#replace original ID with the ID you want
    sed -e "s/10843_20151015/${i}/g" $FEAT_TEMPLATE_PATH > ${i}_L1_WM_delay_${reg}_PPI_R1.fsf
#run analysis run 1
    feat ${i}_L1_WM_delay_${reg}_PPI_R1.fsf
    #replace run 1 with run 2
    sed -e "s/run1/run2/g" -e "s/wm1/wm2/g" -e "s/_1_5/_2_5/g" -e "s/workingmemory_1/workingmemory_2/g" ${i}_L1_WM_delay_${reg}_PPI_R1.fsf > ${i}_L1_WM_delay_${reg}_PPI_R2.fsf
    #run analysis run 2
    feat ${i}_L1_WM_delay_${reg}_PPI_R2.fsf
done
