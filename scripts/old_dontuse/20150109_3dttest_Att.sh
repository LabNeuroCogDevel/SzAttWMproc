#!/bin/bash

# stop if error (-e) and print everything its doing (-x)
#set -xe  

#attempting 3dttest++ whole brain (patients vs. controls

pathData="/Volumes/Phillips/P5/subj"
pathAnal="/Volumes/Phillips/P5/group_analyses/Attn/20150109_Attn"

mask=$HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_mask_3mm.nii

conditions="att_GLT"




cont="sm-20140829 btc_082222014" 
#11339_20141104"

pat="11327_20140911"
#11333_20141017"


cd $pathAnal
for condition in $conditions; do
	# clear the files that build what head/brik to use
        echo -n "" > cont_inputs
        echo -n "" > pat_inputs

	for s in $cont; do

		file=$pathData/$s/contrasts/Att/simpledContrasts_stats+tlrc
		echo "${file}[${condition}#0_Coef]" >> cont_inputs
		cont_inputs="$( cat cont_inputs )"
	done

	for s in $pat; do
	       
		file=$pathData/$s/contrasts/Att/simpledContrasts_stats+tlrc
		echo "${file}[${condition}#0_Coef]" >> pat_inputs
		pat_inputs="$( cat pat_inputs )"
	done



	# check to see if we have repeats
	sort cont_inputs | uniq -c  |sort -n |head -n 2
	sort pat_inputs | uniq -c   |sort -n |head -n 2

         [ -d $condition ] && rm -r $condition
	 mkdir $condition

	 #run test
	 3dttest++ -setA $cont_inputs -setB $pat_inputs -prefix $condition/$condition -mask $mask


done

