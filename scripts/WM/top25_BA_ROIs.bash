#!/bin/bash

#extracting ROIs from 3dttest run on patients vs. controls for WM task

data=/Volumes/Phillips/P5/subj
roi_path=/Volumes/Phillips/P5/scripts/ROIs/BA_spheres
text_files=/Volumes/Phillips/P5/scripts/txt

region="LBA17 LBA40 LBA46  LBA9 RBA17 RBA40 RBA46 RBA9"

cd $data
for d in 1*/; do
  for reg in $region; do

  

	3dBrickStat -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[1] >>${text_files}/cue_ld1_${reg}_t25.txt
        3dBrickStat -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[3] >>${text_files}/cue_ld3_${reg}_t25.txt
	3dBrickStat -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[5]>>${text_files}/delay_ld1_${reg}_t25.txt
	3dBrickStat -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[7]>>${text_files}/delay_ld3_${reg}_t25.txt
        3dBrickStat -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[9]>>${text_files}/probe_ld1_${reg}_t25.txt
	3dBrickStat -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[11]>>${text_files}/probe_ld3_${reg}_t25.txt

    done
done

cd $text_files
paste cue_ld1_LBA17_t25.txt cue_ld1_LBA40_t25.txt cue_ld1_LBA46_t25.txt cue_ld1_LBA9_t25.txt cue_ld1_RBA17_t25.txt cue_ld1_RBA40_t25.txt cue_ld1_RBA46_t25.txt cue_ld1_RBA9_t25.txt > cue_ld1_BA_spheres_t25.txt

paste cue_ld3_LBA17_t25.txt cue_ld3_LBA40_t25.txt cue_ld3_LBA46_t25.txt  cue_ld3_LBA9_t25.txt cue_ld3_RBA17_t25.txt cue_ld3_RBA40_t25.txt cue_ld3_RBA46_t25.txt cue_ld3_RBA9_t25.txt > cue_ld3_BA_spheres_t25.txt

paste delay_ld1_LBA17_t25.txt delay_ld1_LBA40_t25.txt delay_ld1_LBA46_t25.txt delay_ld1_LBA9_t25.txt delay_ld1_RBA17_t25.txt delay_ld1_RBA40_t25.txt delay_ld1_RBA46_t25.txt delay_ld1_RBA9_25.txt > delay_ld1_BA_spheres_t25.txt

paste delay_ld3_LBA17_t25.txt delay_ld3_LBA40_t25.txt delay_ld3_LBA46_t25.txt delay_ld3_LBA9_t25.txt delay_ld3_RBA17_t25.txt delay_ld3_RBA40_t25.txt delay_ld3_RBA46_t25.txt delay_ld3_RBA9_t25.txt > delay_ld3_BA_spheres_t25.txt

paste probe_ld1_LBA17_t25.txt probe_ld1_LBA40_t25.txt probe_ld1_LBA46_t25.txt probe_ld1_LBA9_t25.txt probe_ld1_RBA17_t25.txt probe_ld1_RBA40_t25.txt probe_ld1_RBA46_t25.txt probe_ld1_RBA9_t25.txt > probe_ld1_BA_spheres_t25.txt

paste probe_ld3_LBA17_t25.txt probe_ld3_LBA40_t25.txt probe_ld3_LBA46_t25.txt probe_ld3_LBA9_t25.txt probe_ld3_RBA17_t25.txt probe_ld3_RBA40_t25.txt probe_ld3_RBA46_t25.txt probe_ld3_RBA9_t25.txt > probe_ld3_BA_spheres_t25.txt
