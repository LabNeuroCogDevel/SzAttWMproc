#!/usr/bin/env bash

# use google doc to get list of controls
# limit to only those with preproced workingmemory

# 20180816WF - initial

[ ! -d txt ] && mkdir txt
[ ! -r txt/allsubj.txt ] &&
 curl 'https://docs.google.com/spreadsheets/d/e/2PACX-1vRlGXLx9ZqvQUBZ_koEExYZ94iKZ0hnXFdC75s4cYQNMSwVvFMtd_JluYuOL4h_H124amTFf3RcUZXP/pub?gid=0&single=true&output=tsv' > txt/all_subj.txt

# get all controls
awk '($9=="Control"){print $4}' txt/all_subj.txt > txt/all_contols.txt
cat txt/all_contols.txt | while read ld8; do
   nii=($(ls /Volumes/Phillips/P5/subj/$ld8/preproc/workingmemory_[12]/nfswudktm_mean_func_5.nii.gz 2>/dev/null))
   [ ${#nii[@]} -ne 2 ] && echo "$ld8: != 2 WM (${nii[@]})" >&2 && continue
   echo $ld8 
done > txt/complete_controls.txt
