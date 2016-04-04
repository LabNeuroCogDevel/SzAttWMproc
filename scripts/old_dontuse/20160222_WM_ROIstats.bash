#!/bin/bash

#extracting ROIs from 3dttest run on patients vs. controls for WM task

data=/Volumes/Phillips/P5/subj
roi_path=/Volumes/Phillips/P5/scripts/ROIs/BA_spheres
text_files=/Volumes/Phillips/P5/scripts/txt

region="LBA17" 
#LBA40 LBA46  LBA9 RBA17 RBA40 RBA46 RBA9"

cd $data
for d in 108*/; do
  for reg in $region; do

  

	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[1] | sed "s/^/${d}" >>${text_files}/cue_ld1_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[3]>>${text_files}/cue_ld3_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[5]>>${text_files}/delay_ld1_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[7]>>${text_files}/delay_ld3_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[9]>>${text_files}/probe_ld1_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[11]>>${text_files}/probe_ld3_${reg}.txt

    done
done

cd $text_files
paste cue_ld1_LBA17.txt cue_ld1_LBA40.txt cue_ld1_LBA46.txt cue_ld1_LBA9.txt cue_ld1_RBA17.txt cue_ld1_RBA40.txt cue_ld1_RBA46.txt cue_ld1_RBA9.txt > cue_ld1_BA_spheres.txt

paste cue_ld3_LBA17.txt cue_ld3_LBA40.txt cue_ld3_LBA46.txt  cue_ld3_LBA9.txt cue_ld3_RBA17.txt cue_ld3_RBA40.txt cue_ld3_RBA46.txt cue_ld3_RBA9.txt > cue_ld3_BA_spheres.txt

paste delay_ld1_LBA17.txt delay_ld1_LBA40.txt delay_ld1_LBA46.txt delay_ld1_LBA9.txt delay_ld1_RBA17.txt delay_ld1_RBA40.txt delay_ld1_RBA46.txt delay_ld1_RBA9.txt > delay_ld1.txt

paste delay_ld3_LBA17.txt delay_ld3_LBA40.txt delay_ld3_LBA46.txt delay_ld3_LBA9.txt delay_ld3_RBA17.txt delay_ld3_RBA40.txt delay_ld3_RBA46.txt delay_ld3_RBA9.txt > delay_ld3.txt

paste probe_ld1_LBA17wr.txt probe_ld1_LBA40wr.txt probe_ld1_LBA46wr.txt probe_ld1_LBA9wr.txt probe_ld1_RBA17wr.txt probe_ld1_RBA40wr.txt probe_ld1_RBA46wr.txt probe_ld1_RBA9wr.txt > probe_ld1.txt

paste probe_ld3_LBA17wr.txt probe_ld3_LBA40wr.txt probe_ld3_LBA46wr.txt probe_ld3_LBA9wr.txt probe_ld3_RBA17wr.txt probe_ld3_RBA40wr.txt probe_ld3_RBA46wr.txt probe_ld3_RBA9wr.txt > probe_ld3.txt
