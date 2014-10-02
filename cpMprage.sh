#!/usr/bin/env bash
id=$1
[ -z "$id" ]  && echo "need id as first argument" && exit 1

file="$(find subj/$id/tfl-multiecho-epinav-* -name mprage.nii.gz|tail -n1)"
[ -z "$file" ]  && echo "couldn't find mprage.nii.gz for $id in subj/$id/tfl-multiecho-epinav" && exit 1
echo scp $file open@reese:~/P5/$id.nii.gz
