#!/bin/bash

#extracting ROIs from 3dttest run on patients vs. controls for WM task

data=/Volumes/Phillips/P5/subj
roi_path=/Volumes/Phillips/P5/scripts/ROIs
text_files=/Volumes/Phillips/P5/scripts/txt



region="BBA17 BBA40 BBA46 BBA9"

cd $data
for d in 1*/; do
  for reg in $region; do

  

	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[1]>>${text_files}/cue_ld1_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[3]>>${text_files}/cue_ld3_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[5]>>${text_files}/delay_ld1_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[7]>>${text_files}/delay_ld3_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[9]>>${text_files}/probe_ld1_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[11]>>${text_files}/probe_ld3_${reg}.txt

    done
done

cd $text_files
paste cue_ld1_BBA17.txt cue_ld1_BBA40.txt cue_ld1_BBA46.txt cue_ld1_BBA9.txt > cue_ld1_bl.txt

paste cue_ld3_BBA17.txt cue_ld3_BBA40.txt cue_ld3_BBA46.txt  cue_ld3_BBA9.txt  > cue_ld3_bl.txt

paste delay_ld1_BBA17.txt delay_ld1_BBA40.txt delay_ld1_BBA46.txt delay_ld1_BBA9.txt > delay_ld1_bl.txt

paste delay_ld3_BBA17.txt delay_ld3_BBA40.txt delay_ld3_BBA46.txt delay_ld3_BBA9.txt > delay_ld3_bl.txt

paste probe_ld1_BBA17.txt probe_ld1_BBA40.txt probe_ld1_BBA46.txt probe_ld1_BBA9.txt > probe_ld1_bl.txt

paste probe_ld3_BBA17.txt probe_ld3_BBA40.txt probe_ld3_BBA46.txt probe_ld3_BBA9.txt > probe_ld3_bl.txt


