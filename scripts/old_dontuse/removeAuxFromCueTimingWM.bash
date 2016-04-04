#!/usr/bin/env bash
#scriptdir=$(cd $(dirname $0);pwd)
scriptdir="/Volumes/Phillips/P5/scripts"

for s in $scriptdir/../subj/1*_*/; do
  d="$s/1d/WM/correct_load_wrongtogether"
  [ ! -d $d ] && echo "WHOA: bad dir name? $d" && continue

  cd $d
  for f in cue*; do  
      [[ $f =~ .*noaux.* ]] && continue
      [ -r $f ] || continue
      #sed 's/:[0-9.]+//g' $f > ${f//.1D}_noaux.1D; # sed wont match multiple chrs?
      perl -pe 's/:[0-9.]+//g' $f >${f//.1D}_noaux.1D;
  done

done
