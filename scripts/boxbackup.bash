#!/usr/bin/env bash
rsync -azvhi \
   /Volumes/Phillips/P5 \
   /Volumes/Box.net/backup/Phillips/P5 \
   --files-from=<( find /Volumes/Phillips/P5 -maxdepth 5 -iname '*.*sh' |
                    sed 's:^/Volumes/Phillips/P5/::' )
