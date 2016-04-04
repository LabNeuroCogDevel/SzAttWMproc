#this is for Working Memory behave data
library(plyr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(LNCDR)
#library(LNCDR)
#load all the WM behav files (they've already been run through matlab)
#copy them over from skynet
#WMfiles <- Sys.glob('//10.145.64.109/Phillips/P5/scripts/csv/WorkingMemory*')
WMfiles <- Sys.glob('/Volumes/Phillips/P5/scripts/csv/WorkingMemory*')

#for just one individual
#filename = ('//10.145.64.109/Phillips/P5/scripts/csv/WorkingMemory_11466_20151125_behave.csv')
prefix= '/Volumes/Phillips/P5/scripts/csv/WorkingMemory_'


# get std error
std <- function(x) sd(x)/sqrt(length(x))

#I'm making a function that I can then apply on all my files later on
table_correct<-function(filename){
  subjid <- gsub('_behave.csv','',gsub(prefix,'',filename))
  a<-read.table(filename,sep=',',header=T)
  a<-a[!is.nan(a$Crt),]

  total_cor=length(which(a$Crt==1))
  total_inc=length(which(a$Crt==0))
  total_nors=length(which(a$Crt==-1))
  
  per_cor=total_cor/(total_cor+total_inc)*100
  per_cor_clin=total_cor/(total_cor+total_inc+total_nors)*100
  per_inc=total_inc/(total_cor+total_inc)*100
  per_nors=total_nors/(total_cor+total_inc+total_nors)*100
 
  #average RT for correct trial
  avg_RT<-mean(a$RT[ is.finite(a$RT) & a$Crt==1])
  avg_RT_ld1<-mean(a$RT[ is.finite(a$RT) & a$ld==1 & a$Crt==1])  
  avg_RT_ld3<-mean(a$RT[ is.finite(a$RT) & (a$ld==3|a$ld==4) & a$Crt==1])  
  avg_RT_delay1<-mean(a$RT[ is.finite(a$RT) & a$islongdelay==0 & a$Crt==1])  
  avg_RT_delay3<-mean(a$RT[ is.finite(a$RT) & a$islongdelay==1 & a$Crt==1])
  avg_RT_ld1_delay1<-mean(a$RT[ is.finite(a$RT) & a$ld==1 & a$islongdelay==0 & a$Crt==1])  
  avg_RT_ld1_delay3<-mean(a$RT[ is.finite(a$RT) & a$ld==1 & a$islongdelay==1 & a$Crt==1])  
  avg_RT_ld3_delay1<-mean(a$RT[ is.finite(a$RT) & a$ld==3|a$ld==4 & a$islongdelay==0 & a$Crt==1])  
  avg_RT_ld3_delay3<-mean(a$RT[ is.finite(a$RT) & a$ld==3|a$ld==4 & a$islongdelay==1 & a$Crt==1])  

  #ld1
  ld1_cor<-sum(a$Crt == 1 & a$ld  == 1, na.rm=TRUE)
  ld1_inc<-sum(a$Crt == 0 & a$ld  == 1, na.rm=TRUE)
  ld1_nors<-sum(a$Crt == -1 & a$ld  == 1, na.rm=TRUE)
  ld1_per_cor<-ld1_cor/(ld1_cor+ld1_inc)*100
  ld1_per_inc<-ld1_inc/(ld1_cor+ld1_inc)*100

  
  #ld3
  ld3_cor<-sum(a$Crt == 1 & (a$ld==3|a$ld==4), na.rm=TRUE)
  ld3_inc<-sum(a$Crt == 0 & (a$ld==3|a$ld==4), na.rm=TRUE)
  ld3_nors<-sum(a$Crt == -1 & (a$ld==3|a$ld==4), na.rm=TRUE)
  ld3_per_cor<-ld3_cor/(ld3_cor+ld3_inc)*100
  ld3_per_inc<-ld3_inc/(ld3_cor+ld3_inc)*100
  
  #separate out delay
  #delay1
  delay1_cor<-sum(a$Crt == 1 & a$islongdelay==0, na.rm=TRUE)
  delay1_inc<-sum(a$Crt == 0 & a$islongdelay==0, na.rm=TRUE)
  delay1_nors<-sum(a$Crt == -1 & a$islongdelay==0, na.rm=TRUE)
  delay1_per_cor<-delay1_cor/(delay1_cor+delay1_inc)*100
  delay1_per_inc<-delay1_inc/(delay1_cor+delay1_inc)*100
  
  #delay3
  delay3_cor<-sum(a$Crt == 1 & a$islongdelay==1, na.rm=TRUE)
  delay3_inc<-sum(a$Crt == 0 & a$islongdelay==1, na.rm=TRUE)
  delay3_nors<-sum(a$Crt == -1 & a$islongdelay==1, na.rm=TRUE)
  delay3_per_cor<-delay3_cor/(delay3_cor+delay3_inc)*100
  delay3_per_inc<-delay3_inc/(delay3_cor+delay3_inc)*100
  
  #separate out ld & delay 
  #ld 1, delay1
  ld1_delay1_cor<-sum(a$Crt == 1 & a$ld  == 1 &a$islongdelay==0, na.rm=TRUE)
  ld1_delay1_inc<-sum(a$Crt == 0 & a$ld  == 1 &a$islongdelay==0, na.rm=TRUE)
  ld1_delay1_nors<-sum(a$Crt == -1 & a$ld  == 1 &a$islongdelay==0, na.rm=TRUE)
  ld1_delay1_per_cor<-ld1_delay1_cor/(ld1_delay1_cor+ld1_delay1_inc)*100
  ld1_delay1_per_inc<-ld1_delay1_inc/(ld1_delay1_cor+ld1_delay1_inc)*100

  #ld 1, delay3
  ld1_delay3_cor<-sum(a$Crt == 1 & a$ld  == 1 &a$islongdelay==1, na.rm=TRUE)
  ld1_delay3_inc<-sum(a$Crt == 0 & a$ld  == 1 &a$islongdelay==1, na.rm=TRUE)
  ld1_delay3_nors<-sum(a$Crt == -1 & a$ld  == 1 &a$islongdelay==1, na.rm=TRUE)
  ld1_delay3_per_cor<-ld1_delay3_cor/(ld1_delay3_cor+ld1_delay3_inc)*100
  ld1_delay3_per_inc<-ld1_delay3_inc/(ld1_delay3_cor+ld1_delay3_inc)*100
  
  
  #ld 3, delay1
  ld3_delay1_cor<-sum(a$Crt == 1 & (a$ld==3|a$ld==4) &a$islongdelay==0, na.rm=TRUE)
  ld3_delay1_inc<-sum(a$Crt == 0 & (a$ld==3|a$ld==4) &a$islongdelay==0, na.rm=TRUE)
  ld3_delay1_nors<-sum(a$Crt == -1 & (a$ld==3|a$ld==4) &a$islongdelay==0, na.rm=TRUE)
  ld3_delay1_per_cor<-ld3_delay1_cor/(ld3_delay1_cor+ld3_delay1_inc)*100
  ld3_delay1_per_inc<-ld3_delay1_inc/(ld3_delay1_cor+ld3_delay1_inc)*100
  
  #ld 3, delay3
  ld3_delay3_cor<-sum(a$Crt == 1 & (a$ld==3|a$ld==4) &a$islongdelay==1, na.rm=TRUE)
  ld3_delay3_inc<-sum(a$Crt == 0 & (a$ld==3|a$ld==4) &a$islongdelay==1, na.rm=TRUE)
  ld3_delay3_nors<-sum(a$Crt == -1 & (a$ld==3|a$ld==4) &a$islongdelay==1, na.rm=TRUE)
  ld3_delay3_per_cor<-ld3_delay3_cor/(ld3_delay3_cor+ld3_delay3_inc)*100
  ld3_delay3_per_inc<-ld3_delay3_inc/(ld3_delay3_cor+ld3_delay3_inc)*100
  
  
  #calcualting % correct based on way that Dean & Brian do it (include no response)
  per_cor_clin<-total_cor/(total_cor+total_inc+total_nors)*100
  ld1_per_cor_clin<-ld1_cor/(ld1_cor+ld1_inc+ld1_nors)*100
  ld3_per_cor_clin<-ld3_cor/(ld3_cor+ld3_inc+ld3_nors)*100
  delay1_per_cor_clin<-delay1_cor/(delay1_cor+delay1_inc+delay1_nors)*100
  delay3_per_cor_clin<-delay3_cor/(delay3_cor+delay3_inc+delay3_nors)*100
  ld1_delay1_per_cor_clin<-ld1_delay1_cor/(ld1_delay1_cor+ld1_delay1_inc+ld1_delay1_nors)*100
  ld1_delay3_per_cor_clin<-ld1_delay3_cor/(ld1_delay3_cor+ld1_delay3_inc+ld1_delay3_nors)*100
  ld3_delay1_per_cor_clin<-ld3_delay1_cor/(ld3_delay1_cor+ld3_delay1_inc+ld3_delay1_nors)*100
  ld3_delay3_per_cor_clin<-ld3_delay3_cor/(ld3_delay3_cor+ld3_delay3_inc+ld3_delay3_nors)*100


return(data.frame(subjid, per_cor,ld1_per_cor,ld3_per_cor,delay1_per_cor,delay3_per_cor,ld1_delay1_per_cor, ld1_delay3_per_cor,ld3_delay1_per_cor, ld3_delay3_per_cor,
                  per_cor_clin,ld1_per_cor_clin,ld3_per_cor_clin,delay1_per_cor_clin,delay3_per_cor_clin,ld1_delay1_per_cor_clin,ld1_delay3_per_cor_clin,ld3_delay1_per_cor_clin,ld3_delay3_per_cor_clin,
                  avg_RT,avg_RT_ld1,avg_RT_ld3,avg_RT_delay1,avg_RT_delay3,avg_RT_ld1_delay1,avg_RT_ld1_delay3,avg_RT_ld3_delay1,avg_RT_ld3_delay3))
#return(data.frame(subjid,ld1_same_per_cor,ld1_dif_per_cor,ld3_same_per_cor,ld3_dif_per_cor))
}

#takes elements of a list(all the att files) and applies a function to each of them

data_table<-ldply(WMfiles,table_correct)

#20151208-remove individual w/ load 4 (11327_20140911, 11333_20141017), one individual who could not ocmplete tasks, but hs csv (11364_20`150317)
#20151209- remove individuals w/ less than 50% correct on one of the loads
#11430_20151002- 51% load 3, 48% load 1, row 33
#11402_20150728- 47% load 3, 56% load 1, row 28
data_table1<-subset(data_table, !(ld1_per_cor<50 | ld3_per_cor <50)) #exclude individuals that have <50% correct on one of the loads
  
#read in google doc
subj<-read.delim(file="/Volumes/Phillips/P5/scripts/SubjInfoGoogleSheet_wdx.txt",header=T)
#match the google doc with existing behave files because not all subs completed the tasks
onesIwant<-match(data_table1$subjid,subj$MRID)
#get a new data table with only subs I want
subj2<-subj[onesIwant,]

# filter out those not completed (not in google doc)
data_table2<-merge(data_table1,subj2,by.x="subjid",by.y="MRID")



##########################
##

# dt1 -- parsed behav csv
# dt2 -- merged with google doc, excluded bad performers
# dt3 and 4 exclude columns
# transform data from wide (4 columns ea load x RT and % correct) to wide 3 columns (load, measure, and val)
dt_RTAccLong <- data_table2 %>% 
 # put all % correct into one column (and load into another)
 gather(Load,Correct,ld1_per_cor,ld3_per_cor) %>% 
 # extract load from text
 mutate(Load=gsub('.*(\\d).*','\\1',Load)) %>% 
 # put all RT into one column
 gather(LoadRT,RT,avg_RT_ld1,avg_RT_ld3) %>% 
 # extract load
 mutate(LoadRT=gsub('.*(\\d).*','\\1',LoadRT)) %>% 
 # only grab rows where load matches , remove redudant load info
 filter(LoadRT==Load) %>% select(-LoadRT) %>%
 # put RT and correct into the same column (as meassures)
 gather(measure,val,Correct,RT) %>%
 mutate( Dx    = factor(confirmed_initial_dx2,labels=list('dx1','dx2','dx3','dx4','dx5')),
         Meds  = factor(meds,labels=list("not medicated","medicated"))  ) %>%
 #mutate( Dx = factor(confirmed_initial_dx2,labels=list('First Break','Clinical','Control')) )
 # narrow column list so its easy to look at
 select(subjid,sex,age,Cohort,Dx,Meds,Load,measure,val)


plotMeanAgainstLoadOverCohort <- function(d) {

   # NA controls set to 0, no meds
   d$Meds[is.na(d$Meds)] <- 'not medicated'

   # get mean and sterror
   RTAccsmy <- d %>% group_by(Cohort,Load,measure) %>% summarise_each(funs(mean,std),val)

   # want to dodge based on first grouping (cohort)
   # want sub groups based on meds
   # and want jitter within the sub grouping
   d$jitterdodgepos<- with(d,
     jitter( as.numeric(as.factor(Load)),amount=.05) +  # jitter
     ifelse(Meds=='medicated',-1,1)*.15  +                      # sub group (meds)
     ifelse(Cohort=="Clinical",-1,1)*.2                 # dodging (cohort group)
   )

   # plot
   wp<- ggplot(RTAccsmy) + 
    aes(y=mean,x=Load,fill=Cohort) +
    geom_bar(stat='identity',position='dodge') +
    geom_errorbar(aes(ymin=mean-std,ymax=mean+std),position=position_dodge(.9),width=.25) + 
    geom_point(data=d,
               #position=position_jitterdodge(jitter.width=.3, dodge.width=.9),
               aes(color=Dx,group=Cohort,y=val,
                  shape=Meds,
                  x=jitterdodgepos)
              ) +
    scale_color_manual(values=c("green","black","black","black","black"))  +
    scale_shape_manual(values=c(1,15))

   # lunaize
   #return(lunaize(wp))
   return(wp)
}

wpl <- plotMeanAgainstLoadOverCohort(dt_RTAccLong) + 
   facet_grid(measure~.,scales='free_y') 
print(wpl)

wpl.RT <- subset(dt_RTAccLong,measure=='RT')  %>% 
   plotMeanAgainstLoadOverCohort

wpl.Acc <- subset(dt_RTAccLong,measure=='Correct')  %>% 
   plotMeanAgainstLoadOverCohort

print(wpl)
ggsave(wpl,'meanRT+Acc_facet.png')

