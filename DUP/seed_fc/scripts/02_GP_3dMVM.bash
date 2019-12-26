
masklist=GPmasks.lst

cat $masklist | while read roi; do

3dMVM -prefix ../groupROIanalyses/${roi}_3group_3dMVM_controlMask \
      -bsVars 'Group' \
      -jobs 32 \
      -num_glf 1 \
      -glfLabel 1 Group -glfCode 1 'Group : 1*upp&1*low&1*con' \
      -num_glt 3 \
      -gltLabel 1 'Group_CON-upperSCFU' -gltCode 1 'Group : 1*con -1*upp'\
      -gltLabel 2 'Group_CON-lowerSCFU' -gltCode 2 'Group : 1*con -1*low'\
      -gltLabel 3 'Group_upperSCFU-lowerSCFU' -gltCode 3 'Group : 1*upp -1*low'\
      -dataTable @datatable_${roi}.txt\
      -mask /Volumes/Phillips/P5/DUP/seed_fc/groupROIanalyses/Control_GP_mask+tlrc\
      -overwrite
done
