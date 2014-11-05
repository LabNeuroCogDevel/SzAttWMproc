#!/usr/bin/env bash
host=redrum # defined in ~/.ssh/config

rsync -hivr subj/ $host:~/Luna_DSI/  --include '*/diff113_**' --exclude '*/*' 
