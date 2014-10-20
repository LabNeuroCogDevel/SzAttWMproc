#!/usr/bin/env bash

for sid in sm-20140829 11327_20140911; do
	t1="../subj/$sid/contrasts/WM/template.nii"
	wm="../subj/$sid/contrasts/WM/${sid}_WM_DefaultContrasts_stats+tlrc.HEAD"
	#../subj/11327_20140911/contrasts/Att/simpledContrasts_2runs_stats+tlrc.BRIK
	att="../subj/$sid/contrasts/Att/simpledContrasts_2runs_stats+tlrc.HEAD" 

	# FILES?
	[ ! -r "$t1" -o ! -r "$wm" -o ! -r "$att" ] && echo "cannot read '$t1','$wm', or '$att'" && exit 1

	wmb="$(basename $wm .HEAD)"; 
	attb="$(basename $att .HEAD)";


	# START AFNI: should check socket instead of pid
        #-np 65400
        afni -YESplugouts -niml \
		 -com 'QUIET_PLUGOUTS' \
		 -com "SET_PBAR_NUMBER 12" \
		 -com "OPEN_WINDOW sagittalimage" \
		 -com "OPEN_WINDOW coronalimage" \
		 -com "OPEN_WINDOW axialimage" \
		 -com "SET_PBAR_SIGN +" \
		 -com "SWITCH_FUNCTION $wmb" \
		 -dset $t1 $wm $att &


	sleep 3;
	echo "$sid: did you clusterize?"
	read

	### actually get images
	# use plugout_driver: /opt/ni_tools/afni/README.driver

	# want 
	# *i=>sag: 53 *83/95 = 46
	# *j=> cor: 99 - 18 and 40 (99- because was looking left=right) = 81,59 
	# *k=> ax:  31 58 57 59 61 62 44 

	for p in 0.05 0.005; do
		## WM
		for c in dly dly_load4M1 dly_load4M1; do
		    sb=$(3dinfo -label2index ${c}_GLT#0_Coef   $wm)
		   tsb=$(3dinfo -label2index ${c}_GLT#0_Tstat  $wm)

		   echo "$sb $tsb"
		   [ -z "$sb" -o -z "$tsb" ] && echo no sb ot sb && continue
		   plugout_drive -quit -com "SET_XHAIRS OFF" \
			    -com "SET_ANATOMY $(basename $t1)" \
			    -com "SWITCH_FUNCTION $wmb" \
			    -com "SET_SUBBRICKS -1 $sb $tsb" \
			    -com "SET_THRESHNEW A $p *p" \
			    -com "SET_FUNC_RANGE 60" \
			    \
			    -com "SET_IJK 46 0 0" \
			    -com "SLEEP 200" \
			    -com "SAVE_PNG sagittalimage imgs/${sid}_p${p}_${c}_sag_visual.png" \
			    \
			    -com "SET_IJK 0 81 0" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG coronalimage imgs/${sid}_p${p}_${c}_cor_BA9_10.png" \
			    \
			    -com "SET_IJK 0 59 0" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG coronalimage imgs/${sid}_p${p}_${c}_cor_motivation.png" \
			    \
			    -com "SET_IJK 0 0 31" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_midTempG.png" \
			    \
			    -com "SET_IJK 0 0 58" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_bilat_pat.png" \
			    \
			    -com "SET_IJK 0 0 57" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_bilat_cont.png" \
			    \
			    -com "SET_IJK 0 0 59" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_FEF.png" \
			    \
			    -com "SET_IJK 0 0 61" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_RLateralized.png" \
			    \
			    -com "SET_IJK 0 0 62" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_bilat.png" \
			    \
			    -com "SET_IJK 0 0 44" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_visual.png" \
			    

		done
		## ATT
		for c in pop hab flx; do
		    sb=$(3dinfo -label2index attend_${c}#0_Coef   $att)
		   tsb=$(3dinfo -label2index attend_${c}#0_Tstat  $att)

		   echo "$sb $tsb"
		   [ -z "$sb" -o -z "$tsb" ] && echo no sb ot sb && continue
		   plugout_drive -quit -com "SET_XHAIRS OFF" \
			    -com "SET_ANATOMY $(basename $t1)" \
			    -com "SWITCH_FUNCTION $attb" \
			    -com "SET_SUBBRICKS -1 $sb $tsb" \
			    -com "SET_THRESHNEW A $p *p" \
			    -com "SET_FUNC_RANGE 60" \
			    \
			    -com "SET_IJK 46 0 0" \
			    -com "SLEEP 200" \
			    -com "SAVE_PNG sagittalimage imgs/${sid}_p${p}_${c}_sag_visual.png" \
			    \
			    -com "SET_IJK 0 81 0" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG coronalimage imgs/${sid}_p${p}_${c}_cor_BA9_10.png" \
			    \
			    -com "SET_IJK 0 59 0" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG coronalimage imgs/${sid}_p${p}_${c}_cor_motivation.png" \
			    \
			    -com "SET_IJK 0 0 31" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_midTempG.png" \
			    \
			    -com "SET_IJK 0 0 58" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_bilat_pat.png" \
			    \
			    -com "SET_IJK 0 0 57" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_bilat_cont.png" \
			    \
			    -com "SET_IJK 0 0 59" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_FEF.png" \
			    \
			    -com "SET_IJK 0 0 61" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_RLateralized.png" \
			    \
			    -com "SET_IJK 0 0 62" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_bilat.png" \
			    \
			    -com "SET_IJK 0 0 44" \
			    -com "SLEEP 100" \
			    -com "SAVE_PNG axialimage imgs/${sid}_p${p}_${c}_ax_visual.png" \

		done # END ATT
	done # END P

	plugout_drive -quit -com "QUIT"
       	sleep 3
done # END SUBJ
