#!/bin/bash

#extracting ROIs from 3dttest run on patients vs. controls for WM task

data=/Volumes/Phillips/P5/subj
roi_path=/Volumes/Phillips/P5/scripts/ROIs
text_files=/Volumes/Phillips/P5/scripts/txt

region="LBA17wr LBA40wr LBA46wr  LBA9wr RBA17wr RBA40wr RBA46wr RBA9wr"

cd $data
for d in 1*/; do
  for reg in $region; do

  

	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/Att/bycond_stats+tlrc.[1]>>${text_files}/Popout_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/Att/bycond_stats+tlrc.[3]>>${text_files}/Habitual_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/Att/bycond_stats+tlrc.[5]>>${text_files}/Flexible_${reg}.txt
        
    done
done

cd $text_files
paste Popout_LBA17wr.txt Popout_LBA40wr.txt Popout_LBA46wr.txt Popout_LBA9wr.txt Popout_RBA17wr.txt Popout_RBA40wr.txt Popout_RBA46wr.txt Popout_RBA9wr.txt  > Popout.txt

paste Habitual_LBA17wr.txt Habitual_LBA40wr.txt Habitual_LBA46wr.txt Habitual_LBA9wr.txt Habitual_RBA17wr.txt Habitual_RBA40wr.txt Habitual_RBA46wr.txt Habitual_RBA9wr.txt  > Habitual.txt

paste Flexible_LBA17wr.txt Flexible_LBA40wr.txt Flexible_LBA46wr.txt Flexible_LBA9wr.txt Flexible_RBA17wr.txt Flexible_RBA40wr.txt Flexible_RBA46wr.txt Flexible_RBA9wr.txt  > Flexible.txt




