#!/usr/bin/env bash

SUBJDIR=$(cd ../subj;pwd)
printf "Subj          \tnCens\tnOK\t%%\n"
for censorfile in $SUBJDIR/*/contrasts/Att/censor_total.1D; do

	subjdir=$(dirname $censorfile)
	subj=$(echo $(dirname $censorfile) | cut -d "/" -f6)
	ncensor=$(grep 0 $censorfile | wc -l)
	nok=$(grep 1 $censorfile | wc -l)
	censpct=$(echo "100*$ncensor/($ncensor + $nok)"|bc -l)
	printf "%s\t%d\t%d\t%.2f\n" $subj $ncensor $nok $censpct

done
