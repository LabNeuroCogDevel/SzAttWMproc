#!/usr/bin/env bash

set -x

scriptdir=$(pwd)

./makeDataTable_WM2.bash > datatable.txt

3dMVM -prefix ../group_analyses/WM/HRF_2016-02-26/hrf_mvm \
	-wsVars 'Load*Delay*Time' \
	-bsVars 'Group' \
	-jobs 32 \
	-dataTable @datatable.txt \
	-overwrite
