
# prep done by not-control
# 01 - generate rois
#    3dAFNItoNIFTI -prefix /Volumes/Phillips/P5/DUP/DUP_PPI/ROIs/${reg}.nii.gz /Volumes/Phillips/P5/DUP/DUP_PPI/ROIs/${reg}+tlrc
# 02 - extract timeseries
#    fslmeants -i ${data}/${d}/preproc/workingmemory_1/nfswudktm_workingmemory_1_5.nii.gz -o ${d}_${r}_wm1.txt -m /Volumes/Phillips/P5/DUP/DUP_PPI/ROIs/${r}.nii
#    fslmeants -i ${data}/${d}/preproc/workingmemory_2/nfswudktm_workingmemory_2_5.nii.gz -o ${d}_${r}_wm2.txt -m /Volumes/Phillips/P5/DUP/DUP_PPI/ROIs/${r}.nii

# feat for each run x roi x condition (delay only)
# 03 - feat_L1
      p=delay

           outfolder="/Volumes/Phillips/P5/DUP/DUP_PPI/subj/$i/PPI_run${run}_${p}_${r}.feat" # TODO what should this be
           grep Finished $outfolder/report.html >/dev/null 2>/dev/null && echo skipping $outfolder && continue

           # also check if we have repeat runs ( +.feat), and bail if we do
           extra=$(ls -d /Volumes/Phillips/P5/DUP/DUP_PPI/subj/$i/PPI_run${run}_${p}_${r}+*.feat 2>/dev/null)
           [ -n "$extra" ] && echo "already run, weirdness happening, skipping b/c $extra" && continue

           # remove if we have and we want to redo (REMOVEFILES set to yes) -- only redo if incomplete b/c of above checks
           [ "$REMOVEFILES" == "yes" -a -d $outfolder ] && rm -r $outfolder

           # dont rerun if we have
           if [ ! -d  $outfolder ]; then 
             [ -n "$DRYRUN" ] && echo create $outfolder && continue
             export FSLPARALLEL=""
             feat ${i}_L1_WM_${p}_${r}_PPI_R${run}.fsf  &
             echo "${i}_${r}_R$run -> $outfolder"
           fi

# 03 - abunch2
            cd /Volumes/Phillips/P5/DUP/DUP_PPI/design/
            FEAT_TEMPLATE_PATH=/Volumes/Phillips/P5/DUP/DUP_PPI/design/template_L1_WM_delay_LVSI.fsf          
            #go to designs directory
           #replace original ID with the ID you want
            sed -e 's/10843_20151015/${subj}/g' ${FEAT_TEMPLATE_PATH} > ${subj}_L1_WM_${phase}_${reg}_PPI_R1.fsf #changing subj id  R1==run1
           #run analysis run 1
           feat ${subj}_L2_WM_${phase}_${reg}_PPI_R1.fsf #once has been changed, running the feat
           echo ${subj}_feat
           #replace run 1 with run 2
           #sed -e "s/run1/run2/g" -e "s/wm1/wm2/g" -e "s/_1_5/_2_5/g" -e "s/workingmemory_1/workingmemory_2/g" ${subj}_L1_WM_${phase}_${reg}_PPI_R1.fsf > ${subj}_L1_WM_${phase}_${reg}_PPI_R2.fsf
           #run analysis run 2
           #  feat ${subj}_L1_WM_${phase}_${reg}_PPI_R2.fsf


# 03 - ./03_PPI_feat_L1_collapse_LDs_abunch.bash"
  sed -e "s/10843_20151015/${i}/g" $FEAT_TEMPLATE_PATH > ${i}_L1_WM_${phase}_${reg}_collapse_lds_PPI_R1.fsf
    #run analysis run 1
   feat ${i}_L1_WM_${phase}_${reg}_collapse_lds_PPI_R1.fsf
 #replace run 1 with run 2
    sed -e "s/run1/run2/g" -e "s/wm1/wm2/g" -e "s/_1_5/_2_5/g" -e "s/workingmemory_1/workingmemory_2/g" ${i}_L1_WM_${phase}_${reg}_collapse_lds_PPI_R1.fsf > ${i}_L1_WM_${phase}_${reg}_collapse_lds_PPI_R2.fsf
    #run analysis run 2
    feat ${i}_L1_WM_${phase}_${reg}_collapse_lds_PPI_R2.fsf

# 03 - ./03_PPI_feat_L1_collapse_LDs_abunchver2.bash
    FEAT_TEMPLATE_PATH=/Volumes/Phillips/P5/DUP/DUP_PPI/design/template_L1_WM_delay_RDLPFC_BA9_collapse_lds_PPI_R1.fsf      
    #go to designs directory
    cd /Volumes/Phillips/P5/DUP/DUP_PPI/design/
    #replace original ID with the ID you want
    sed -e 's/10843_20151015/${subj}/g' ${FEAT_TEMPLATE_PATH} > ${subj}_L1_WM_${phase}_${reg}_collapse_lds_PPI_R1.fsf #changing subj id 

# 03 - ../03_PPI_feat_L1_design_delay.bash                  
     FEAT_TEMPLATE_PATH=/Volumes/Phillips/P5/DUP/DUP_PPI/design/template_L1_WM_delay/template_L1_WM_delay_${r}_PPI_R1.fsf
     pwd
     echo "$i $p $r => $FEAT_TEMPLATE_PATH"
     [ ! -r $FEAT_TEMPLATE_PATH ] && echo "no template file $FEAT_TEMPLATE_PATH! skipping" && continue
     #replace original ID with the ID you want
     sed -e "s/10843_20151015/${i}/g" $FEAT_TEMPLATE_PATH > ${i}_L1_WM_delay_${r}_PPI_R1.fsf
     #echo ${i}_done
     # also change the ROI
   
     #run analysis run 1
     # echo "run 1"
     #feat ${i}_L1_WM_${p}_${r}_PPI_R1.fsf
     
     #replace run 1 with run 2
     sed -e "s/run1/run2/g" \
         -e "s/wm1/wm2/g" \
         -e "s/_1_5/_2_5/g" \
         -e "s/workingmemory_1/workingmemory_2/g" \
         -e "s:/Volumes/Phillips/P5/DUP/DUP_PPI/subj/\([0-9_]*\)/1d/WM/:/Volumes/Phillips/P5/DUP/DUP_PPI/subj/\1/1d/:g" \
          ${i}_L1_WM_delay_${r}_PPI_R1.fsf > ${i}_L1_WM_delay_${r}_PPI_R2.fsf
                   
     feat ${i}_L1_WM_${p}_${r}_PPI_R2.fsf
                   
#  04 -  ./04_PPI_feat_L2.bash (updatefeatreg for each run)
                      
