#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
scriptdir=$(cd $(dirname $0);pwd)
reg="/Volumes/Phillips/P5/DUP/DUP_PPI/reg"
[ ! -d $reg ]  && echo "cannot normalize, no $reg!" && exit 1

#
# ## tell FSL we are using MNI template ##
#
# give L1 feat directories
# if given none, will run on all
#

# run on whats given or run on all L1's
runon="$@"
[[ -z "$@" ]] && runon="$(ls -d PPI/*/*L1*.feat)"

for L1dir in $runon; do
    cd $scriptdir
    [ ! -d $L1dir ] && echo "bad L1 dir! $L1dir" && continue
    ! grep Finished $L1dir/report.html -q 2>/dev/null && echo "$L1dir is not finished!" && continue
    [ -d $L1dir/reg ] && echo "have $L1dir/reg, skipping updatefeatreg" && continue

    echo "$L1dir copy reg, run updatefeatreg"
    cp -r ${reg} $L1dir/reg
    cp -r $L1dir/example_func.nii.gz $L1dir/reg/example_func.nii.gz
    cd $L1dir
    updatefeatreg .
done
