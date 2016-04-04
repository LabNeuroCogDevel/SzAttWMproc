 #!/usr/bin/env bash

scriptdir=/Volumes/Phillips/P5/scripts

cd $scriptdir

#20151026- don't have MB data for 10843_20151015, 11430_20151012, 11433_20150924#, 11454_20151019 11228_20150309 11327_20140911 11333_20141017 11339_20141104 11#340_20141031 11341_20141118 11348_20141119 11349_20141124 11351_20141202 11352_#20141230 11354_20141205 11355_20141230 11356_20150105


ID="11494_20160202 11485_20160112 11483_20160128 11479_20160108 11478_20151230 11477_20160108 11476_20151219 11473_20151217 11466_20151125 11454_20151019 11354_20141205 11367_20150430 10843_20151015 11228_20150309 11327_20140911 11333_20141017 11339_20141104 11340_20141031 11341_20141118 11348_20141119 11349_20141124 11351_20141202 11352_20141230 11355_20141230 11356_20150105 11357_20150122 11358_20150129 11359_20150203 11360_20150129 11363_20150310 11365_20150407 11367_20150430 11368_20150505 11369_20150519 11374_20150529 11386_20150619 11390_20150721 11402_20150728 11407_20150716 11423_20150916 11424_20150908 11430_20151002 11432_20150922 11433_20150924 11418_20151201"



for i in ${ID}
do

    #./deconvolve_Att_bycond.bash ${i}
    #./deconvolve_Att_bycond_HRF.bash ${i}
    #./deconvolve_Att_bycond_Pati.bash ${i}
    #./deconvolve_WM_bycorrect_wrongtogether_sepdly_HRF.bash ${i}
    #./deconvolve_Att_bycond_Pati_BLOCK.bash ${i}
    #./deconvolve_WM_bycorrect_allsepdly_HRF.bash ${i}
    #./deconvolve_WM_bycorrect_sepwrong_sepdly_SPMG3.bash ${i}
    ./deconvolve_WM_bycorrect_sepwrong_dlymod_lateral.bash ${i}
    #./deconvolve_WM_bycorrect_wrongtogether_dlymod.sh ${i}
    #./deconvolve_WM_bycorrect_wrongtogether_HRF.bash ${i}
    #./deconvolve_only2Att.bash ${i}
    #./deconvolve_only2Att_cueattend.bash ${i}
    #./deconvolve_only2Att_bydir.sh ${i}
    #./deconvolve_WM_basic_bycorrect.bash ${i}
    #./deconvolve_Att_bycond_HRF.bash ${i}
    #./deconvolve_Att_bycond.bash ${i}

done
