#!/bin/bash

#extracting ROIs from 3dttest run on patients vs. controls for WM task

data=/Volumes/Phillips/P5/subj
roi_path=/Volumes/Phillips/P5/scripts/ROIs/BA_spheres
text_files=/Volumes/Phillips/P5/scripts/txt

region="LBA17 LBA40 LBA46 LBA9 RBA17 RBA40 RBA46 RBA9"

cd $data
for d in 1*/; do
  for reg in $region; do

  

	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_sepwrong_sepdly_SPMG3+tlrc.[15] | sed "s/^/${d}" >>${text_files}/delay1_ld1_late_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_sepwrong_sepdly_SPMG3+tlrc.[21] | sed "s/^/${d}" >>${text_files}/delay3_ld1_late_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_sepwrong_sepdly_SPMG3+tlrc.[27] | sed "s/^/${d}" >>${text_files}/delay1_ld3_late_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_sepwrong_sepdly_SPMG3+tlrc.[33] | sed "s/^/${d}" >>${text_files}/delay3_ld3_late_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_sepwrong_sepdly_SPMG3+tlrc.[13] | sed "s/^/${d}" >>${text_files}/delay1_ld1_amp_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_sepwrong_sepdly_SPMG3+tlrc.[19] | sed "s/^/${d}" >>${text_files}/delay3_ld1_amp_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_sepwrong_sepdly_SPMG3+tlrc.[25] | sed "s/^/${d}" >>${text_files}/delay1_ld3_amp_${reg}.txt
	3dROIstats -quiet -mask ${roi_path}/${reg}_10mm+tlrc.HEAD ${data}/${d}/contrasts/WM/stats_WM_correct_load_sepwrong_sepdly_SPMG3+tlrc.[31] | sed "s/^/${d}" >>${text_files}/delay3_ld3_amp_${reg}.txt
	
    done
done

cd $text_files
paste delay1_ld1_late_LBA17.txt delay1_ld1_late_LBA40.txt delay1_ld1_late_LBA46.txt delay1_ld1_late_LBA9.txt delay1_ld1_late_RBA17.txt delay1_ld1_late_RBA40.txt delay1_ld1_late_RBA46.txt delay1_ld1_late_RBA9.txt > delay1_ld1_late_BA_spheres.txt

paste delay3_ld1_late_LBA17.txt delay3_ld1_late_LBA40.txt delay3_ld1_late_LBA46.txt delay3_ld1_late_LBA9.txt delay3_ld1_late_RBA17.txt delay3_ld1_late_RBA40.txt delay3_ld1_late_RBA46.txt delay3_ld1_late_RBA9.txt > delay3_ld1_late_BA_spheres.txt

paste delay1_ld3_late_LBA17.txt delay1_ld3_late_LBA40.txt delay1_ld3_late_LBA46.txt delay1_ld3_late_LBA9.txt delay1_ld3_late_RBA17.txt delay1_ld3_late_RBA40.txt delay1_ld3_late_RBA46.txt delay1_ld3_late_RBA9.txt > delay1_ld3_late_BA_spheres.txt

paste delay3_ld3_late_LBA17.txt delay3_ld3_late_LBA40.txt delay3_ld3_late_LBA46.txt delay3_ld3_late_LBA9.txt delay3_ld3_late_RBA17.txt delay3_ld3_late_RBA40.txt delay3_ld3_late_RBA46.txt delay3_ld3_late_RBA9.txt > delay3_ld3_late_BA_spheres.txt

paste delay3_ld3_amp_LBA17.txt delay3_ld3_amp_LBA40.txt delay3_ld3_amp_LBA46.txt delay3_ld3_amp_LBA9.txt delay3_ld3_amp_RBA17.txt delay3_ld3_amp_RBA40.txt delay3_ld3_amp_RBA46.txt delay3_ld3_amp_RBA9.txt > delay3_ld3_amp_BA_spheres.txt

paste delay1_ld1_amp_LBA17.txt delay1_ld1_amp_LBA40.txt delay1_ld1_amp_LBA46.txt delay1_ld1_amp_LBA9.txt delay1_ld1_amp_RBA17.txt delay1_ld1_amp_RBA40.txt delay1_ld1_amp_RBA46.txt delay1_ld1_amp_RBA9.txt > delay1_ld1_amp_BA_spheres.txt

paste delay3_ld1_amp_LBA17.txt delay3_ld1_amp_LBA40.txt delay3_ld1_amp_LBA46.txt delay3_ld1_amp_LBA9.txt delay3_ld1_amp_RBA17.txt delay3_ld1_amp_RBA40.txt delay3_ld1_amp_RBA46.txt delay3_ld1_amp_RBA9.txt > delay3_ld1_amp_BA_spheres.txt

paste delay1_ld3_amp_LBA17.txt delay1_ld3_amp_LBA40.txt delay1_ld3_amp_LBA46.txt delay1_ld3_amp_LBA9.txt delay1_ld3_amp_RBA17.txt delay1_ld3_amp_RBA40.txt delay1_ld3_amp_RBA46.txt delay1_ld3_amp_RBA9.txt > delay1_ld3_amp_BA_spheres.txt




