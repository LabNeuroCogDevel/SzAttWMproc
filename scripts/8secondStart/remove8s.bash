#!/usr/bin/env bash
set -e

# give me a directory
# I will rename it to old
# and make every 1D file delayed by 8 seconds if matches runno

[ -z "$2" ]  && echo "USAGE: $0 runno 1dfolder
runno like '1' or '[12]' 
1dfolder like /Volumes/Phillips/P5/subj/11500_20160215/1d/WM/correct_load_wrongtogether_dlymod
EXAMPLE:
$0 2 /Volumes/Phillips/P5/subj/11500_20160215/1d/WM/correct_load_wrongtogether_dlymod
$0 1 /Volumes/Phillips/P5/subj/11500_20160215/1d/Att/bycorrect/" && exit 1

#

export RUNNO=$1;shift
# remove 8 seconds
remove8s(){
  for f in $@; do
    perl -i -sane '
  for $f (@F){
   # split if we have : durations
   @a=split/:/, $f; 

   # only change if we are on the right run number
   if($. =~ m/$ENV{RUNNO}/x){
     $a[0]=sprintf("%.2f", $a[0]-8 );
   }

   # when we have a time
   if( $a[0]>0 ){
     # print the onset
     print $a[0]; 
     # print duration if there is any
     print ":$a[1]" if $a[1]; 
     # print a space
     print " "
    }
   } 
   print "\n"' $f; 
done
}


# check we have what we need: a directory with 1D files
[ -z "$1" ] && echo "need a 1D directory as input" && exit 1
[ ! -r "$1" ] && echo "$1 is not a directory!" && exit 1
[ $(find "$1"/ -type f -iname '*1D' | wc -l ) -le 0 ] && echo "$1 has no 1D files!" && exit 1

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
if [ -L "$dir" -a -r "$dirfull" ]; then 
  ! [  -r "$dirfull" -a -r "$dirnew" ] && echo "failed previous run; fix by hand" && exit 1
  unlink $dir;
  [ -r $dir ] && echo "error removing $dir" && exit 1
  mv $dirfull $dir;
  [ -d $dirnew ] && rm -r $dirnew
fi

# make a copy
# move to new name (remove if existed previous)
# link new name to original name
# --- all this is so if we rerun matlab 1d genrator
# we still have the original and the truncated

[ -r "$dirfull" ] && echo "error: $dirfull exists already!" && exit 1 
[ -r "$dirnew" ] && echo " error: $dirnew exists already!" && exit 1

cp -r  $dir ${dirfull}
mv $dir ${dirnew}
[ -r $dir ] && echo "error, $dir was not moved to $dirnew" && exit 1

ln -s ${dirnew} $dir

cd $dir

remove8s $(find . -iname "*1D" -type f )

echo -e "# [$(date +%F) $orgdir] removed first 8 seconds from 1d in $dir\n\t$0 $1" >> ../NOTES

cd $orgdir
