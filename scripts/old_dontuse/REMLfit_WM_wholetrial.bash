#!/usr/bin/env bash
set -xe

#Orient ourselves in terms of directories
scriptdir=$(cd $(dirname $0);pwd)
subjsdir=$scriptdir/../subj  

#Find subject
s=$1
[ -z "$s" ] && echo "need a subject directory as first argument!" && exit 1

#Look in different places for the subject
[ ! -d "$s" ] && s=$scriptdir/$1
[ ! -d "$s" ] && s=$scriptdir/../$1
[ ! -d "$s" ] && s=$subjsdir/$1
[ ! -d "$s" ] && echo "cannot find subj dir ($1 or $s)" && exit 1

#Go into the directory we found and make sure we have absolute path
#Reset s to be the subject again
cd $s
sdir=$(pwd);
s=$(basename $sdir)
prefix=${s}_WM_wholetrial

#Locate contrasts directory for each subject
contrasts=$sdir/contrasts/WM/wholetrial
cd $contrasts

#Run 3dREMLfit to obtain estimates for parameters after prewhitening of residuals (using a voxel-wise ARMA(1,1) model).
reml_cmd=stats_${prefix}.REML_cmd
reml_cmd_edited=${reml_cmd}_edited
sed 's/-tout/-GOFORIT 99 -tout/' $reml_cmd> $reml_cmd_edited #add -GOFORIT & jobs options (used '-tout' arbitrarily, as insertion point)
chmod 777 $reml_cmd_edited
./$reml_cmd_edited
