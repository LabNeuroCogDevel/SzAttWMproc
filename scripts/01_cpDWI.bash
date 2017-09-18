#!/usr/bin/env bash

# WF 20170111 - copy dsi data to open@reese for brian

set -e
cd $(dirname $0)
source funcs.src.bash

for s in $SUBJDIR/1*/; do 
   dwidir=$(find $s -maxdepth 1 -iname 'diff113_current_PA_1152x1152*' -type d)
   if [ -z "$dwidir" ]; then
      dwidir=($(find $s -maxdepth 1 -iname 'diff*' -type d))
      warn "no dwi dir for $s" 
      [ ${#dwidir} -gt 0 ] && echo "\thave ${#dwidir} diff dirs: ${dwidir[@]}" >&2
      continue
   fi
   DWI/00_cpDTI_singleSubj.bash $s;
done
