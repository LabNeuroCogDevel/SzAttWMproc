 #!/usr/bin/env bash

scriptdir=/Volumes/Phillips/P5/scripts/WM

cd $scriptdir

ID="11228_20150309 11277_20160311 11333_20141017 11339_20141104 11340_20141031 11341_20141118 11348_20141119 11349_20141124 11351_20141202 11352_20141230 11354_20141205 11355_20141230 11356_20150105 11357_20150122 11358_20150129 11359_20150203 11360_20150129 11363_20150310 11365_20150407 11367_20150430 11368_20150505 11369_20150519 11374_20150529 11386_20150619 11390_20150721 11407_20150716 11418_20151201 11423_20150916 11424_20150908 11432_20150922 11433_20150924 11452_20160404 11454_20151019 11466_20151125 11473_20151217 11476_20151219 11477_20160108 11478_20151230 11479_20160108 11483_20160128 11485_20160112 11494_20160202 11505_20160216 11511_20160307 11512_20160510 11523_20160329 11524_20160425 11525_20160412 11532_20160413 11534_20160418 11539_2016043 11545_20160518 11552_20160611  11465_20160711 11556_20160705 11559_20160719 11563_20160718 11567_20160805 11569_20160812"

#10843_20151015

for i in ${ID}
do

    #./deconvolve_Att_bycond.bash ${i}
    #./deconvolve_Att_bycond_HRF.bash ${i}
    #./deconvolve_Att_bycond_Pati.bash ${i}
    #./deconvolve_WM_bycorrect_wrongtogether_sepdly_HRF.bash ${i}
    #./deconvolve_Att_bycond_Pati_BLOCK.bash ${i}
    #./deconvolve_WM_bycorrect_allsepdly_HRF.bash ${i}
    #./deconvolve_WM_bycorrect_sepwrong_sepdly_SPMG3.bash ${i}
    #./deconvolve_WM_bycorrect_sepwrong_dlymod_lateral.bash ${i}
    #./deconvolve_WM_bycorrect_wrongtogether_dlymod.sh ${i}
    #./deconvolve_WM_bycorrect_wrongtogether_HRF.bash ${i}
    #./deconvolve_only2Att.bash ${i}
    #./deconvolve_only2Att_cueattend.bash ${i}
    #./deconvolve_only2Att_bydir.sh ${i}
    #./deconvolve_WM_basic_bycorrect.bash ${i}
    #./deconvolve_Att_bycond_HRF.bash ${i}
    #./deconvolve_Att_bycond.bash ${i}
    #./deconvolve_WM_final.bash ${i}
    ./deconvolve_WM_sepload_probeRT.bash ${i}

done
