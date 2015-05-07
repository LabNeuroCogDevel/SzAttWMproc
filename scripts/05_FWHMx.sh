#!/bin/bash

data=/Volumes/Phillips/P5/subj
conditions="att_pop"

#go to where you want to put the  data
cd $data

#get a list of all the directories
for condition in $conditions; do
for d in 1*/; do

d=$(basename $d)


num=$(3dFWHMx -automask -input $d/contrasts/Att/simpledContrasts_2runs_stats2+tlrc[1])
echo $num $d

done |tee ${condition}_all| perl -slane '$sum[$_] += $F[$_] for (0..2); END{print join " ", map {$_/$.} @sum}'>${condition}_for3dclustsim_cleanEPI.txt
done

#to get only time point 1
#cd /data/Luna2/Reward/Rest/Mari
#cut -d' ' -f1-4 -s cleanEPI | Rio -d' ' -nre 'df %>% separate(V4,c("luna","date")) %>% group_by(luna) %>% filter(min_rank(date)==1) %>% ungroup %>% select(V1,V2,V3) %>% summarise_each(funs(mean))'

# (cut) grab fields 1-4 (all of them) in Ramyg_all, (-s) skip lines without all fields (exist where there was no brick for fwhm, but still printed luna_date)
# pipe that to R to filter and average (columns come in names as V1-4)
#cut -d' ' -f1-4 -s Ramyg_all |
#Rio -d' ' -nre 'df %>%
#separate(V4,c("luna","date")) %>%  # make luna and date from luna_date
#group_by(luna) %>%                 # group by luna ids
    # filter(min_rank(date)==1) %>%      # select the lowest of the dates (for each luna)
#ungroup %>%                        # remove the luna grouping
  #select(V1,V2,V3) %>%               # select only the X Y Z columns
# summarise_each(funs(mean))         # get the mean of for each column


