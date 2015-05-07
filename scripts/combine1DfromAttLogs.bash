#!/usr/bin/env bash
 
#  given some 1D files in directory 1/ and 2/ represting 1D for a run 
#  (output of ../../../../../scripts/generate1DfromAttLogs.pl)
#   combine into one 1D file
#   inside the combine/ directory
# see /Volumes/Phillips/P5/subj/11357_20150122/1d/Att/fromlog/Makefile

# first argument is the directory that has 1 and 2

[ -n "$1" ] && cd $1

function timeorstar {
 fn=$1
 # print the file
 [ -r $fn ] && cat $fn && return
 #otherwise its a star
 echo "*"

}
[ -d combined ] || mkdir combined

# find all the differnt 1D file names between the two runs
ls 1/*1D 2/*1D |
 xargs -n1 basename |
 sort |
 uniq|
 while read fn; do 
    echo "$(timeorstar 1/$fn)\n$(timeorstar 2/$fn)"> combined/$fn
 done
