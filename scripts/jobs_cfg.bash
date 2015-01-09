#!/usr/bin/env bash
MAXJOBS=3
SLEEPTIME=100

# wait for SLEEPTIME between checking that MAXJOBS are not being run
# sleep and job vars can be modified each sleep inteval if the first argument is provided
#  first argument is settings file to be sourced
function waitForJobs {
  # use first argument as settings file
  # source if given
  [ -n "$1" -a -r "$1" ] && source $1;

  njobs=$(jobs -p |wc -l)
  while [[ "$njobs" -ge "$MAXJOBS" ]]; do
    [ -n "$1" -a -r "$1" ] && source $1;
    echo "sleeping for $SLEEPTIME, waiting for njobs ($njobs) to be < $MAXJOBS"
    sleep $SLEEPTIME
  done
}
