#!/usr/bin/env bash
scale=400
ft=.jpg
for f in *$ft; do 
  convert -scale ${scale}% $f imgs/$(basename $f $ft)-${scale}.jpg ;
done
