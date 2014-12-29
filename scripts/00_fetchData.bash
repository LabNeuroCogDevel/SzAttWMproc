#!/usr/bin/env bash

# make sure we are running from within the scripts directory
cd $(dirname $0)

# rsync is a file transfer program capable of efficient remote update via a fast differencing algorithm
#-v=verbose
#-r=recursive into directory
#-z=compress file data during transfer
#-h=output numbers in a human readable format
#Will is getting the data from Wallace and copying it to Phillips
#size-only: it checks to see if the sizes on wallace match the file sizes on Skynet, if they don't match it does copy over
rsync -rvzhi foranw@wallace:/data/Luna1/Raw/P5Sz/ ../subj/ --size-only

# copy google sheet with IDs and info in it
url=https://docs.google.com/spreadsheets/d/1tklWovQor7Nt3m0oWsiP2RPRwDauIS8QUtY4la2kHac
#curl is a command to transfer a url
#copy the google sheet into a text file
curl -s "$url/export?format=tsv" > SubjInfoGoogleSheet.txt
