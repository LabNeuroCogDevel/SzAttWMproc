#!/usr/bin/env bash

###
# 00_moveControls - moves control directories into directory called "Controls" 
#
#to run this script you need to run 'chmod +x 01_connectivity.bash' which makes it 'e(x)ecutable'
#    so we can do './01_connectivity.bash


cd $(dirname $0)

cd ../subjs

# a list of controls
CONLIST=Controls.lst 

cat $CONLIST | while read subj; do
  
  # test if file does not exist -- when it doesnt say so and go to next id (continue)
  if [ ! -r $restfile ]; then 
     echo "cannot find $restfile" 
     continue
  fi

  mv $subj Controls/
  
 done
 echo "done."
