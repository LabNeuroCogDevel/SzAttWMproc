#!/usr/bin/env bash

type=Popout
starttr=0
endtr=20
[ -n "$1" ] && type=$1
[ -n "$2" ] && starttr=$2
[ -n "$3" ] && endtr=$3

src="${type}+tlrc"

scriptdir=$(pwd)

$scriptdir/makeDataTable_WM.bash ${src} ${starttr} ${endtr} > datatable_${type}.txt
cat datatable_${type}.txt
$scriptdir/makeDataTable_WM.bash ${src} ${starttr} ${endtr} 1 > datatable_${type}_patients.txt
$scriptdir/makeDataTable_WM.bash ${src} ${starttr} ${endtr} 2 > datatable_${type}_controls.txt


#3dMVM -prefix /Volumes/Phillips/P5/group_analyses/WM/HRF_$(date +%F)/HRF2_${type}_patients \
      #-wsVars 'Time' \
      #-bsVars '1' \
      #-jobs 4 \
      #-dataTable @datatable_${type}_patients.txt

#3dMVM -prefix /Volumes/Phillips/P5/group_analyses/WM/HRF_$(date +%F)/HRF2_${type}_controls \
      #-wsVars 'Time' \
      #-bsVars '1' \
      #-jobs 4 \
      #-dataTable @datatable_${type}_controls.txt

3dMVM -prefix /Volumes/Phillips/P5/group_analyses/WM/HRF_$(date +%F)/HRF2_${type}_c_v_p \
      -wsVars 'Time' \
      -bsVars 'Group' \
      -jobs 4 \
      -dataTable @datatable_${type}.txt
