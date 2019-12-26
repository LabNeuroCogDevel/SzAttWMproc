
masklist=hip_dlpfc_masks.lst

cat $masklist | while read roi; do

3dMVM -prefix ../groupROIanalyses/${roi}_3group_backgroundWM_3dMVM \
      -bsVars 'Group' \
      -jobs 32 \
      -num_glf 1 \
      -glfLabel 1 Group -glfCode 1 'Group : 1*sz&1*af&1*con' \
      -num_glt 3 \
      -gltLabel 1 'Group_CON-SZ' -gltCode 1 'Group : 1*con -1*sz'\
      -gltLabel 2 'Group_CON-AF' -gltCode 2 'Group : 1*con -1*af'\
      -gltLabel 3 'Group_SZ-AF' -gltCode 3 'Group : 1*sz -1*af'\
      -dataTable @datatable_${roi}.txt\
      -mask BIN_EXEC_HIPPO_converted.nii.gz
      -overwrite
done
