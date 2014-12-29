#!/usr/bin/env bash

# run from within scripts directory
cd $(dirname $0)

host=redrum # defined in ~/.ssh/config

echo "*tin37#"
rsync -hivr ../subj/ $host:~/Luna_DSI/  --include '*/gre_field_mapping_**' --include '*/diff113_**' --exclude '*/*'  --size-only

