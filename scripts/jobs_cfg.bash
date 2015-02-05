#!/usr/bin/env bash
MAXJOBS=4
SLEEPTIME=100

# wait for SLEEPTIME between checking that MAXJOBS are not being run
# sleep and job vars can be modified each sleep inteval if the first argument is provided
#  first argument is settings file to be sourced
function waitForJobs {
  # use first argument as settings file
  jobscnfg="$1"
  # source if given
  [ -n "$jobscnfg" -a -r "$jobscnfg" ] && source "$jobscnfg";

  njobs=$(jobs -p |wc -l)
  i=1;
  while [[ "$njobs" -ge "$MAXJOBS" ]]; do
    [ -n "$jobscnfg" -a -r "$jobscnfg" ] && source "$jobscnfg";
    echo "$i $(date +%F-%H:%M) njobs >= MAXJOBS (${njobs// }>=$MAXJOBS); waiting ${SLEEPTIME}s "
    #jobs|sed 's/^/	/'
    sleep $SLEEPTIME
    let i++
    njobs=$(jobs -p |wc -l)
  done
}
