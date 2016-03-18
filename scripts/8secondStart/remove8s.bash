#!/usr/bin/env bash
set -e
#
# give me a directory
# I will rename it to old
# and make every 1D file delayed by 8 seconds

# remove 8 seconds
remove8s(){
  perl -i -sane '
  for $f (@F){
   @a=split/:/, $f; 
   $a[0]=sprintf("%.2f", $a[0]-8 );
   if( $a[0]>0 ){
     print $a[0]; 
     print ":$a[1]" if $a[1]; 
     print " "
    }
   }' $@
 }

# check we have what we need: a directory with 1D files
[ -z "$1" ] && echo "need a 1D directory as input" && exit 1
[ ! -d "$1" ] && echo "$1 is not a directory!" && exit 1
[ $(find "$1" -type f -iname '*1D' | wc -l ) -le 0 ] && echo "$1 has no 1D files!" && exit 1

orgdir=$(pwd)
cd $(dirname "$1")

# get dir name of current/original
dir=$(basename "$1")
# what we will name the original directory
dirfull="${dir}_fulltime"
dirnew="${dir}_remove8secs"


# dont redo things
[ -z "$REDO" -a -r $dirfull ] && echo -e "$dirfull exists run\n\t REDO=1 $0 $1" && exit 1

# unless we are told to
if [ -l $dir -a -r "$dirfull" ]; then 
  unlink $dir;
  mv $dirfull $dir;
  [ -d $dirnew ] && rm -r $dirnew
fi

# make a copy
# move to new name (remove if existed previous)
# link new name to original name
# --- all this is so if we rerun matlab 1d genrator
# we still have the original and the truncated

[ ! -r "$dirfull" ] && cp -r  $dir ${dirfull}
[ -d $dirnew ] && rm -r $dirnew
mv $dir ${dirnew}
ln -s ${dirnew} $dir
cd $dir

remove8s $(find . -iname "*1D" -type f )

echo -e "# [$(date +%F) $orgdir] removed first 8 seconds from 1d in $dir\n\t$0 $1" >> ../NOTES

cd $orgdir
