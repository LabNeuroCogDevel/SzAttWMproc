#!/usr/bin/env bash

# rsync is a file transfer program capable of efficient remote update via a fast differencing algorithm
#-v=verbose
#-r=recursive into directory
#-z=compress file data during transfer
#-h=output numbers in a human readable format
#Will is getting the data from Wallace and copying it to Phillips
rsync -rvzhi foranw@wallace:/data/Luna1/Raw/P5Sz/ ./subj/ --size-only

# copy google sheet
url=https://docs.google.com/spreadsheets/d/1tklWovQor7Nt3m0oWsiP2RPRwDauIS8QUtY4la2kHac
curl -s "$url/export?format=tsv" > SubjInfoGoogleSheet.txt
