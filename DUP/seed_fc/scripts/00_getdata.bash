#!/usr/bin/env bash

# above is 'shebang' describing what interepter to use for running the code below.
# we sould use e.g. Rscript, python, octave in addition to bash or sh
# bash and sh are different. bash does more. sh is "portable"
# NOTE: edited 6/21/2018 to get additional participant data from addPatients.lst
# NOTE: edite 10/19/2018 to get additional participant data from controls (changed subjroot) from needMasks.lst 

###
# 00_getdata.bash  -- put data into subj folder for all DUP subjects
#
# Some notes:
# 1)this script may look large, but it's heavily commented
#   see   sed 's/#.*//;/^[ ]*$/d' 00_getdata.bash 
#   really, there are only 15 lines 
# 2) to run this script i've already run 'chmod +x 00_getdata.bash' which makes it 'e(x)ecutable'
#    so we can do './00_getdata.bash'
#    we can always do 'bash ./00_getdata.bash'


# we want to be in the same directory as the script
cd $(dirname $0)
# just a percaution.  incase we or someone else runs the script from within a different directory
# '$0'  is the script ($1 is the first argument passed to the script)
# '$( )'  captures the output of a command

# where does subject data live?
SUBJROOT=../subjs/Controls


# a list of subjects
#DUPLIST=DUP.lst
#CONTROLLIST=Controls.lst
ADDPTSLIST=Controls.lst

# for each subject that has DUP measure
# other ways to write this:
#  for subj in $(cat $DUPLIST); do done  # will break if DUPLIST is very large
#  while read subj; do done < $DUPLIST   # hard to read if look is long
#  while read subj; do done <<< $(cat $DUPLIST)  # worst of both

cat $ADDPTSLIST | while read subj; do
  restfile=/Volumes/Phillips/P5/subj/$subj/preproc/rest/brnswudktm_rest_5.nii.gz

  # without checks this loop does:
  # ln -s $restfile ../subjs/$subj/

  # everything below is to make sure nothing breaks while doing this
  # i.e. - dead links to nonexistant files (make sure refence rest file exists)
  #      - trying to link to directory that doesnt exist (mkdir if needed)
  #      - errors when trying to write over links that already exist (only create links when we haven't)

  # test if file does not exist -- when it doesnt say so and go to next id (continue)
  if [ ! -r $restfile ]; then 
     echo "cannot find $restfile" 
     continue
     # lesser than 'break'
  fi
  # [ ! -r $restfile ] && echo asdfasdf && continue

  # where are we putting this data
  thissubjdir=$SUBJROOT/$subj/
  # what to call our newly linked file 
  linkto=$thissubjdir/brnswudktm_rest_5.nii.gz

  # check to see if we already have the directory. make it if not
  # shorter form of 'if test; then; fi'
  [ ! -d $thissubjdir ] && mkdir $thissubjdir

  # if we haven't already linked it in, do so
  [ -r $linkto ] && continue

  # make a link to the resting state data
  # we could use cp to make a copy. 
  # but that would take up a lot of disk space and be slow 
  # we are not planing on making any chages to the data
  # we just want it in a new place
  ln -s $restfile $linkto
done
