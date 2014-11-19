#!/usr/bin/env bash
host=redrum # defined in ~/.ssh/config

echo "*tin37#"
rsync -hivr subj/ $host:~/Luna_DSI/  --include '*/diff113_**' --exclude '*/*' 

