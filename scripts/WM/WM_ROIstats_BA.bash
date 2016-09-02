#!/bin/bash

#extracting ROIs from 3dttest run on patients vs. controls for WM task

data=/Volumes/Phillips/P5/subj
roi_path=/Volumes/Phillips/P5/scripts/ROIs

region="LBA17wr LBA40wr LBA46wr LBA5wr LBA7wr LBA9wr RBA17wr RBA40wr RBA46wr RBA5wr RBA7wr RBA9wr"

cd $data
for d in 1*/; do
  for reg in $region; do

  

	3dROIstats -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[1] >>cue_ld1_${reg}.txt
	3dROIstats -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[3]>>cue_ld3_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[5]>>delay_ld1_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[7]>>delay_ld3_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[9]>>probe_ld1_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_wrongtogether_dlymod+tlrc.[11]>>probe_ld3_${reg}.txt

    done
done


paste cue_ld1_LBA17wr.txt cue_ld1_LBA40wr.txt cue_ld1_LBA46wr.txt cue_ld1_LBA5wr.txt cue_ld1_LBA7wr.txt cue_ld1_LBA9wr.txt cue_ld1_RBA17wr.txt cue_ld1_RBA40wr.txt cue_ld1_RBA46wr.txt cue_ld1_RBA5wr.txt cue_ld1_RBA7wr.txt cue_ld1_RBA9wr.txt > cue_ld1.txt

paste cue_ld3_LBA17wr.txt cue_ld3_LBA40wr.txt cue_ld3_LBA46wr.txt cue_ld3_LBA5wr.txt cue_ld3_LBA7wr.txt cue_ld3_LBA9wr.txt cue_ld3_RBA17wr.txt cue_ld3_RBA40wr.txt cue_ld3_RBA46wr.txt cue_ld3_RBA5wr.txt cue_ld3_RBA7wr.txt cue_ld3_RBA9wr.txt > cue_ld3.txt

paste delay_ld1_LBA17wr.txt delay_ld1_LBA40wr.txt delay_ld1_LBA46wr.txt delay_ld1_LBA5wr.txt delay_ld1_LBA7wr.txt delay_ld1_LBA9wr.txt delay_ld1_RBA17wr.txt delay_ld1_RBA40wr.txt delay_ld1_RBA46wr.txt delay_ld1_RBA5wr.txt delay_ld1_RBA7wr.txt delay_ld1_RBA9wr.txt > delay_ld1.txt

paste delay_ld3_LBA17wr.txt delay_ld3_LBA40wr.txt delay_ld3_LBA46wr.txt delay_ld3_LBA5wr.txt delay_ld3_LBA7wr.txt delay_ld3_LBA9wr.txt delay_ld3_RBA17wr.txt delay_ld3_RBA40wr.txt delay_ld3_RBA46wr.txt delay_ld3_RBA5wr.txt delay_ld3_RBA7wr.txt delay_ld3_RBA9wr.txt > delay_ld3.txt

paste probe_ld1_LBA17wr.txt probe_ld1_LBA40wr.txt probe_ld1_LBA46wr.txt probe_ld1_LBA5wr.txt probe_ld1_LBA7wr.txt probe_ld1_LBA9wr.txt probe_ld1_RBA17wr.txt probe_ld1_RBA40wr.txt probe_ld1_RBA46wr.txt probe_ld1_RBA5wr.txt probe_ld1_RBA7wr.txt probe_ld1_RBA9wr.txt > probe_ld1.txt

paste probe_ld3_LBA17wr.txt probe_ld3_LBA40wr.txt probe_ld3_LBA46wr.txt probe_ld3_LBA5wr.txt probe_ld3_LBA7wr.txt probe_ld3_LBA9wr.txt probe_ld3_RBA17wr.txt probe_ld3_RBA40wr.txt probe_ld3_RBA46wr.txt probe_ld3_RBA5wr.txt probe_ld3_RBA7wr.txt probe_ld3_RBA9wr.txt > probe_ld3.txt
