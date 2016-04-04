#!/bin/bash

3dttest++ -setA \
/Volumes/Phillips/P5/subj/sm-20140829/contrasts/Att/simpledContrasts_2runs_stats+tlrc.BRIK[att_GLT#0_Coef] \
/Volumes/Phillips/P5/subj/btc_08222014/contrasts/Att/simpledContrasts_2runs_stats+tlrc.BRIK[att_GLT#0_Coef] \
/Volumes/Phillips/P5/subj/11339_20141104/contrasts/Att/simpledContrasts_2runs_stats+tlrc.BRIK[att_GLT#0_Coef] \
-setB \
/Volumes/Phillips/P5/subj/11327_20140911/contrasts/Att/simpledContrasts_2runs_stats+tlrc.BRIK[att_GLT#0_Coef] \
/Volumes/Phillips/P5/subj/11333_20141017/contrasts/Att/simpledContrasts_2runs_stats+tlrc.BRIK[att_GLT#0_Coef] \
-prefix /Volumes/Phillips/P5/group_analyses/Att/20150109/att_GLT  -mask $HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_mask_2.3mm.nii

